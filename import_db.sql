CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,

  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_followers (
  id INTEGER PRIMARY KEY,

  follower_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (follower_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,

  reply_text VARCHAR(255),
  question_id INTEGER NOT NULL,
  reply_id INTEGER,
  replier_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (replier_id) REFERENCES users(id)

);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,

  liker_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (liker_id) REFERENCES users(id),
  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Adam', 'Russell'),
  ('Saumil', 'Christian'),
  ('Sid', 'Raval'),
  ('Felix', 'Thea'),
  ('Daniel', 'Baker');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('When does the class end?', 'I have to leave at 6, when does the class end?',
  (SELECT id FROM users WHERE fname = 'Adam' AND lname = 'Russell')),

  ('Where is my money?!', 'YOU OWE ME MONEY, WHERE IS IT?',
  (SELECT id FROM users WHERE fname = 'Saumil' AND lname = 'Christian')),

  ('What is for lunch?', 'I am hungry, what are we getting for lunch?',
  (SELECT id FROM users WHERE fname = 'Sid' AND lname = 'Raval')),

  ('What is ruby?', 'I want to know more about Ruby, what is it?',
  (SELECT id FROM users WHERE fname = 'Felix' AND lname = 'Thea')),

  ('What time does the class start?', 'Im not a morning person, what time do I    need to get up?',
  (SELECT id FROM users WHERE fname = 'Daniel' AND lname = 'Baker'));

INSERT INTO
  question_followers (follower_id, question_id)
VALUES
  (1, 5),
  (2, 4),
  (3, 2),
  (4, 3),
  (5, 1),
  (1, 2),
  (2, 2),
  (4, 2),
  (5, 2),
  (1, 3),
  (2, 3),
  (3, 3);

INSERT INTO
  replies (reply_text, question_id, reply_id, replier_id)
VALUES
  ('6PM', 1, NULL, 2),
  ('I will have it tomorrow', 2, NULL, 3),
  ('Sushi', 3, NULL, 4),
  ('No it is not sushi, it is human flesh', 3, 3, 5),
  ('No I need the money NOW!', 2, 2, 2);

INSERT INTO
  question_likes (liker_id, question_id, author_id)
VALUES
  (1, 2, (SELECT author_id FROM questions WHERE questions.id = 2)),
  (2, 3, (SELECT author_id FROM questions WHERE questions.id = 3)),
  (3, 2, (SELECT author_id FROM questions WHERE questions.id = 2)),
  (4, 2, (SELECT author_id FROM questions WHERE questions.id = 2)),
  (5, 3, (SELECT author_id FROM questions WHERE questions.id = 3)),
  (1, 5, (SELECT author_id FROM questions WHERE questions.id = 5)),
  (2, 4, (SELECT author_id FROM questions WHERE questions.id = 4));