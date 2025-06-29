-- DATABASE: SkillSphere
CREATE DATABASE IF NOT EXISTS SkillSphere;
USE SkillSphere;

-- CREATE TABLES

CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_date TIMESTAMP
);

CREATE TABLE Skills (
    skill_id INT PRIMARY KEY,
    skill_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    skill_category VARCHAR(50),
    parent_skill_id INT,
    FOREIGN KEY (parent_skill_id) REFERENCES Skills(skill_id)
);

CREATE TABLE Learning_Resources (
    resource_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    resource_type ENUM('Video', 'Article', 'Course', 'Book', 'Project', 'Mentor Session') NOT NULL,
    url VARCHAR(255),
    estimated_duration_mins INT,
    difficulty_level ENUM('Beginner', 'Intermediate', 'Advanced'),
    date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Resource_Skills (
    resource_skill_id INT PRIMARY KEY,
    resource_id INT NOT NULL,
    skill_id INT NOT NULL,
    coverage_percentage DECIMAL(5,2),
    FOREIGN KEY (resource_id) REFERENCES Learning_Resources(resource_id),
    FOREIGN KEY (skill_id) REFERENCES Skills(skill_id),
    UNIQUE (resource_id, skill_id)
);

CREATE TABLE User_Skills (
    user_skill_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    skill_id INT NOT NULL,
    proficiency_level DECIMAL(5,2) DEFAULT 0.0 CHECK (proficiency_level >= 0.0 AND proficiency_level <= 1.0),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (skill_id) REFERENCES Skills(skill_id),
    UNIQUE (user_id, skill_id)
);

CREATE TABLE Goals (
    goal_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    goal_name VARCHAR(255) NOT NULL,
    description TEXT,
    target_date DATE,
    status ENUM('Pending', 'In Progress', 'Completed', 'Abandoned') DEFAULT 'Pending',
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Goal_Skills (
    goal_skill_id INT PRIMARY KEY,
    goal_id INT NOT NULL,
    skill_id INT NOT NULL,
    required_proficiency DECIMAL(5,2) NOT NULL CHECK (required_proficiency >= 0.0 AND required_proficiency <= 1.0),
    FOREIGN KEY (goal_id) REFERENCES Goals(goal_id),
    FOREIGN KEY (skill_id) REFERENCES Skills(skill_id),
    UNIQUE (goal_id, skill_id)
);

CREATE TABLE Learning_Paths (
    path_id INT PRIMARY KEY,
    path_name VARCHAR(255) NOT NULL,
    description TEXT,
    creator_user_id INT,
    target_goal_id INT,
    is_public BOOLEAN DEFAULT FALSE,
    creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (creator_user_id) REFERENCES Users(user_id),
    FOREIGN KEY (target_goal_id) REFERENCES Goals(goal_id)
);

CREATE TABLE Learning_Path_Steps (
    step_id INT PRIMARY KEY,
    path_id INT NOT NULL,
    step_order INT NOT NULL,
    skill_id INT,
    resource_id INT,
    FOREIGN KEY (path_id) REFERENCES Learning_Paths(path_id),
    FOREIGN KEY (skill_id) REFERENCES Skills(skill_id),
    FOREIGN KEY (resource_id) REFERENCES Learning_Resources(resource_id),
    CHECK (skill_id IS NOT NULL OR resource_id IS NOT NULL),
    UNIQUE (path_id, step_order)
);

CREATE TABLE User_Learning_Activity (
    activity_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    resource_id INT NOT NULL,
    activity_type ENUM('Started', 'InProgress', 'Completed', 'Skipped', 'Reviewed') NOT NULL,
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP,
    progress_percentage DECIMAL(5,2),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (resource_id) REFERENCES Learning_Resources(resource_id)
);

CREATE TABLE User_Resource_Ratings (
    rating_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    resource_id INT NOT NULL,
    rating_score INT NOT NULL CHECK (rating_score >= 1 AND rating_score <= 5),
    comments TEXT,
    rating_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (resource_id) REFERENCES Learning_Resources(resource_id),
    UNIQUE (user_id, resource_id)
);

-- INSERT SAMPLE DATA

INSERT INTO Users VALUES 
(1, 'alice', 'alice@example.com', 'hashed_pwd_1', DEFAULT, NULL),
(2, 'bob', 'bob@example.com', 'hashed_pwd_2', DEFAULT, NULL),
(3, 'charlie', 'charlie@example.com', 'hashed_pwd_3', DEFAULT, NULL);

INSERT INTO Skills VALUES 
(1, 'Python Programming', 'Intro to Python', 'Programming', NULL),
(2, 'Data Analysis', 'Using tools like Excel and Pandas', 'Data Science', NULL),
(3, 'Machine Learning', 'Supervised and Unsupervised Learning', 'Data Science', 2);

INSERT INTO Goals VALUES 
(1, 1, 'Become Data Analyst', 'Master skills in data analysis', '2025-12-31', 'In Progress', DEFAULT),
(2, 2, 'Improve Communication', 'Enhance speaking confidence', '2025-08-15', 'Pending', DEFAULT);

INSERT INTO Learning_Resources VALUES 
(1, 'Intro to Python', 'A beginner’s guide to Python.', 'Video', 'http://example.com/python', 60, 'Beginner', DEFAULT),
(2, 'Advanced ML Course', 'Deep dive into ML algorithms.', 'Course', 'http://example.com/ml', 180, 'Advanced', DEFAULT),
(3, 'Communication Tips', 'Boost your communication.', 'Article', 'http://example.com/comm', 30, 'Beginner', DEFAULT);

-- SAMPLE QUERIES

SELECT * FROM Users;

SELECT Goals.goal_name, Users.username 
FROM Goals 
JOIN Users ON Goals.user_id = Users.user_id;

SELECT s1.skill_name AS Skill, s2.skill_name AS Parent 
FROM Skills s1 
LEFT JOIN Skills s2 ON s1.parent_skill_id = s2.skill_id;

SELECT status, COUNT(*) 
FROM Goals 
GROUP BY status;

SELECT * 
FROM Learning_Resources 
WHERE resource_type = 'Course' AND estimated_duration_mins > 60;

SELECT title, difficulty_level 
FROM Learning_Resources;

SELECT goal_name, target_date 
FROM Goals 
ORDER BY target_date ASC;

SELECT difficulty_level, SUM(estimated_duration_mins) 
FROM Learning_Resources 
GROUP BY difficulty_level;

SELECT Users.username, COUNT(Goals.goal_id) 
FROM Users 
LEFT JOIN Goals ON Users.user_id = Goals.user_id 
GROUP BY Users.username;

SELECT * 
FROM Skills 
WHERE skill_category = 'Data Science';
