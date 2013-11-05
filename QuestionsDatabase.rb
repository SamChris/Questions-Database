require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super("questions.db")
    self.results_as_hash = true
    self.type_translation = true
  end
end

class User

  def self.all

    results = QuestionsDatabase.instance.execute("SELECT * FROM users")
    results.map { |result| User.new(result) }
  end

  attr_accessor :id, :fname, :lname

  def initialize(options = {})
    @id = options["id"]
    @fname = options["fname"]
    @lname = options["lname"]
  end

  def followed_questions
    QuestionsDatabase.instance.execute()
  end

  def create
    raise "already saved!" unless self.id.nil?

    # execute an INSERT; the '?' gets replaced with the value name. The
    # '?' lets us separate SQL commands from data, improving
    # readability, and also safety (lookup SQL injection attack on
    # wikipedia).
    QuestionsDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.find_by_id(id)
    query_arr = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        users
      WHERE
        users.id = ?
    SQL
    self.new(query_arr[0])
  end

  def self.find_by_name(fname, lname)
    query_arr = QuestionsDatabase.instance.execute(<<-SQL, *params)
      SELECT
        users.id, users.fname, users.lname
      FROM
        users
      WHERE
        users.fname = ? AND users.lname = ?
    SQL
    self.new(query_arr[0])
  end

  def fname
    QuestionsDatabase.instance.execute("SELECT fname FROM users")
  end

  def lname
    QuestionsDatabase.instance.execute("SELECT lname FROM users")
  end

  def authored_questions
    questions_arr = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      questions.author_id, questions.title, questions.body
    FROM
      questions
    WHERE
      questions.author_id = ?
    SQL
    questions_arr
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end
end

class Question

  def self.all
    results = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    results.map { |result| Question.new(result) }
  end

  attr_accessor :id, :title, :body, :author_id


  def initialize(options = {})
    @id = options["id"]
    @title = options["title"]
    @body = options["body"]
    @author_id = options["author_id"]
  end

  def create
    raise "already saved!" unless self.id.nil?

    QuestionsDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        users (title, body, author_id)
      VALUES
        (?, ?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.find_by_id(id)
    query_arr = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        questions.id, questions.title, questions.body, questions.author_id
      FROM
        questions
      WHERE
        questions.id = ?
    SQL
    self.new(query_arr[0])
  end

  def title
    QuestionsDatabase.instance.execute("SELECT title FROM questions")
  end

  def self.find_by_author_id(author_id)
    questions_arr = QuestionsDatabase.instance.execute(<<-SQL, author_id)
    SELECT
      questions.title, questions.body, questions.author_id
    FROM
      questions
    WHERE
      questions.author_id = ?
    SQL
    questions_arr
  end

  def author
    QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      users.fname, users.lname
    FROM
      users
    WHERE
      users.id =
        (SELECT
          questions.author_id
        FROM
          questions
        WHERE
          questions.id = ?)
    SQL

  end


  def replies
    Reply.find_by_question_id(self.id)
  end


end

class Question_Follower

  def self.all
    results = QuestionsDatabase.instance.execute("SELECT * FROM question_followers")
    results.map { |result| Question_Follower.new(result) }
  end

  attr_accessor :id, :follower_id, :question_id

  def initialize(options = {})
    @id = options["id"]
    @follower_id = options["follower_id"]
    @question_id = options["question_id"]
  end

  def self.followed_questions_for_user_id(user_id)
    questions_arr = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT que.id, que.title, que.body, que.author_id
    FROM questions AS que
    INNER JOIN question_followers AS qf
    ON qf.question_id = que.id
    WHERE   qf.follower_id  = ?
    SQL
    followed = questions_arr.map do |followed_hash|
      Question.new(followed_hash)
    end
    followed
  end


  def self.followers_for_question_id(q_id)
    followers_arr = QuestionsDatabase.instance.execute(<<-SQL, q_id)
    SELECT followers.fname, followers.lname
    FROM users AS followers
    INNER JOIN question_followers
    ON question_followers.follower_id = followers.id
    WHERE question_followers.question_id = ?
    SQL
    followers = followers_arr.map do |follower_hash|
      User.new(follower_hash)
    end
    followers
  end

  def create
    raise "already saved!" unless self.id.nil?

    QuestionsDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        users (follower_id, question_id)
      VALUES
        (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.find_by_id(id)
    query_arr = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        question_followers.id, question_followers.follower_id, question_followers.question_id
      FROM
        question_followers
      WHERE
        question_followers.id = ?
    SQL
    self.new(query_arr[0])
  end
end

class Reply

  def self.all
    results = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    results.map { |result| Reply.new(result) }
  end

  attr_accessor :id, :reply_text, :question_id, :reply_id, :replier_id

  def initialize(options = {})
    @id = options["id"]
    @reply_text = options["reply_text"]
    @question_id = options["question_id"]
    @reply_id = options["reply_id"]
    @replier_id = options["replier_id"]
  end

  def create
    raise "already saved!" unless self.id.nil?

    QuestionsDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        users (reply_text, question_id, reply_id, replier_id)
      VALUES
        (?, ?, ?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.find_by_id(id)
    query_arr = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        replies.id, replies.reply_text, replies.question_id, replies.reply_id, replies.replier_id
      FROM
        replies
      WHERE
        replies.id = ?
    SQL
    self.new(query_arr[0])
  end


  def self.find_by_question_id(id)
    replies_arr =
    QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        replies.reply_text, replies.question_id, replies.reply_id, replies.replier_id
      FROM
        replies
      WHERE
        replies.question_id = ?
    SQL
    reply_objects = replies_arr.map do |reply_hash|
      self.new(reply_hash)
    end

    reply_objects
  end


  def self.find_by_user_id(id)
    replies_arr =
    QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        replies.reply_text, replies.question_id, replies.reply_id, replies.replier_id
      FROM
        replies
      WHERE
        replies.replier_id = ?
      SQL
    reply_objects = replies_arr.map do |reply_hash|
      self.new(reply_hash)
    end

    reply_objects
  end

  def author
    query_arr = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        replies.id, replies.reply_text, replies.reply_id, replies.replier_id
      FROM
        replies
      WHERE
        replies.id = ?
    SQL
    self.new(query_arr[0])
  end

  def question
    question_arr = QuestionsDatabase.instance.execute(<<-SQL, @question_id)
    SELECT
      questions.id, questions.title, questions.body, questions.author_id
    FROM
      questions
    WHERE
      questions.id = ?
    SQL

    question_objects = question_arr.map do |question_hash|
      Question.new(question_hash)
    end

    question_objects
  end

  def parent_reply
    reply_arr = QuestionsDatabase.instance.execute(<<-SQL, @reply_id)
    SELECT
      replies.reply_text, replies.question_id, replies.reply_id, replies.replier_id
    FROM
      replies
    WHERE
      replies.id = ?
    SQL

    reply_objects = reply_arr.map do |reply_hash|
      Reply.new(reply_hash)
    end

    reply_objects
  end

  def child_replies
    children_arr = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT
      replies.reply_text, replies.question_id, replies.reply_id, replies.replier_id
    FROM
      replies
    WHERE
      replies.reply_id = ?
    SQL
  end

end

class Question_Like

  def self.all
    results = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    results.map { |result| Question_Like.new(result) }
  end

  attr_accessor :id, :liker_id, :question_id, :author_id

  def initialize(options = {})
    @id = options["id"]
    @liker_id = options["liker_id"]
    @question_id = options["question_id"]
    @author_id = options["author_id"]
  end

  def create
    raise "already saved!" unless self.id.nil?

    QuestionsDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        users (liker_id, question_id, author_id)
      VALUES
        (?, ?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.find_by_id(id)
    query_arr = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        question_likes.id, question_likes.liker_id, question_likes.question_id, questions_likes.author_id
      FROM
        question_likes
      WHERE
        question_likes.id = ?
    SQL
    self.new(query_arr[0])
  end

end









