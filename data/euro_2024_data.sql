TRUNCATE points RESTART IDENTITY CASCADE;
TRUNCATE scoring_system RESTART IDENTITY CASCADE;
TRUNCATE prediction RESTART IDENTITY CASCADE;
TRUNCATE emails RESTART IDENTITY CASCADE;
TRUNCATE match RESTART IDENTITY CASCADE;
TRUNCATE tournament_role RESTART IDENTITY CASCADE;
TRUNCATE team RESTART IDENTITY CASCADE;
TRUNCATE meta_group_map RESTART IDENTITY CASCADE;
TRUNCATE meta_group RESTART IDENTITY CASCADE;
TRUNCATE base_group RESTART IDENTITY CASCADE;
TRUNCATE stage RESTART IDENTITY CASCADE;
TRUNCATE venue RESTART IDENTITY CASCADE;
TRUNCATE broadcaster RESTART IDENTITY CASCADE;
TRUNCATE user_role RESTART IDENTITY CASCADE;
TRUNCATE role RESTART IDENTITY CASCADE;
TRUNCATE remember_me RESTART IDENTITY CASCADE;
TRUNCATE users RESTART IDENTITY CASCADE;

INSERT INTO users
    (user_name,    email,                                  pword) VALUES
    ('Mr. Mean',   'mrmean@julianrimet.com',               '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Mr. Median', 'mrmedian@julianrimet.com',             '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Mr. Mode',   'mrmode@julianrimet.com',               '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Maccas',     'james.macadie@telerealtrillium.com',   '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Clare Mac',  'clare@macadie.co.uk',                  '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6');

INSERT INTO role (name) VALUES
    ('Admin'),
    ('Mr Mean'),
    ('Mr Median'),
    ('Mr Mode');

INSERT INTO user_role (user_id, role_id) VALUES
    (4, 1),
    (1, 2),
    (2, 3),
    (3, 4);

INSERT INTO broadcaster (name) VALUES
    ('BBC'),
    ('ITV'),
    ('TBD');

INSERT INTO venue
    (name,                  city,            capacity) VALUES
    ('Olympiastadion',      'Berlin',        74461),
    ('Allianz Arena',       'Munich',        70076),
    ('Westfalenstadion',    'Dortmund',      65849),
    ('Arena AufSchalke',    'Gelsenkirchen', 54740),
    ('Waldstadion',         'Frankfurt',     54697),
    ('MHPArena',            'Stuttgart',     54244),
    ('Volksparkstadion',    'Hamburg',       52245),
    ('Merkur Spiel-Arena',  'Dusseldorf',    51031),
    ('RheinEnergieStadion', 'Cologne',       49827),
    ('Red Bull Arena',      'Leipzig',       42959);


INSERT INTO stage (name) VALUES
    ('Group Stages'),
    ('Round of 16'),
    ('Quarter Finals'),
    ('Semi Finals'),
    ('Final');

INSERT INTO base_group (name) VALUES
    ('A'),
    ('B'),
    ('C'),
    ('D'),
    ('E'),
    ('F');

INSERT INTO meta_group (name) VALUES
    ('A'),
    ('B'),
    ('C'),
    ('D'),
    ('E'),
    ('F'),
    ('A/B/C'),
    ('D/E/F'),
    ('A/D/E/F'),
    ('A/B/C/D');

INSERT INTO meta_group_map (meta_group_id, group_id) VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (6, 6),
    (7, 1),
    (7, 2),
    (7, 3),
    (8, 4),
    (8, 5),
    (8, 6),
    (9, 1),
    (9, 4),
    (9, 5),
    (9, 6),
    (10, 1),
    (10, 2),
    (10, 3),
    (10, 4);

INSERT INTO team (name, short_name) VALUES
    ('Germany',        'GER'),
    ('Scotland',       'SCO'),
    ('Hungary',        'HUN'),
    ('Switzerland',    'SUI'),
    ('Spain',          'ESP'),
    ('Croatia',        'CRO'),
    ('Italy',          'ITA'),
    ('Albania',        'ALB'),
    ('Slovenia',       'SVN'),
    ('Denmark',        'DEN'),
    ('Serbia',         'SRB'),
    ('England',        'ENG'),
    ('Poland',         'POL'),
    ('Netherlands',    'NED'),
    ('Austria',        'AUS'),
    ('France',         'FRA'),
    ('Belgium',        'BEL'),
    ('Slovakia',       'SLO'),
    ('Romania',        'ROM'),
    ('Ukraine',        'UKR'),
    ('Turkey',         'TUR'),
    ('Georgia',        'GEO'),
    ('Portugal',       'POR'),
    ('Czech Republic', 'CZE');

INSERT INTO tournament_role
    (name,                        team_id, from_match_id, from_group_id, stage_id) VALUES
    ('Group A Team 1',            1,       NULL,          1,             1),
    ('Group A Team 2',            2,       NULL,          1,             1),
    ('Group A Team 3',            3,       NULL,          1,             1),
    ('Group A Team 4',            4,       NULL,          1,             1),
    ('Group B Team 1',            5,       NULL,          2,             1),
    ('Group B Team 2',            6,       NULL,          2,             1),
    ('Group B Team 3',            7,       NULL,          2,             1),
    ('Group B Team 4',            8,       NULL,          2,             1),
    ('Group C Team 1',            9,       NULL,          3,             1),
    ('Group C Team 2',            10,      NULL,          3,             1),
    ('Group C Team 3',            11,      NULL,          3,             1),
    ('Group C Team 4',            12,      NULL,          3,             1),
    ('Group D Team 1',            13,      NULL,          4,             1),
    ('Group D Team 2',            14,      NULL,          4,             1),
    ('Group D Team 3',            15,      NULL,          4,             1),
    ('Group D Team 4',            16,      NULL,          4,             1),
    ('Group E Team 1',            17,      NULL,          5,             1),
    ('Group E Team 2',            18,      NULL,          5,             1),
    ('Group E Team 3',            19,      NULL,          5,             1),
    ('Group E Team 4',            20,      NULL,          5,             1),
    ('Group F Team 1',            21,      NULL,          6,             1),
    ('Group F Team 2',            22,      NULL,          6,             1),
    ('Group F Team 3',            23,      NULL,          6,             1),
    ('Group F Team 4',            24,      NULL,          6,             1),
    ('Winner Group A',            NULL,    NULL,          1,             2),
    ('Runner Up Group A',         NULL,    NULL,          1,             2),
    ('Winner Group B',            NULL,    NULL,          2,             2),
    ('Runner Up Group B',         NULL,    NULL,          2,             2),
    ('Winner Group C',            NULL,    NULL,          3,             2),
    ('Runner Up Group C',         NULL,    NULL,          3,             2),
    ('Winner Group D',            NULL,    NULL,          4,             2),
    ('Runner Up Group D',         NULL,    NULL,          4,             2),
    ('Winner Group E',            NULL,    NULL,          5,             2),
    ('Runner Up Group E',         NULL,    NULL,          5,             2),
    ('Winner Group F',            NULL,    NULL,          6,             2),
    ('Runner Up Group F',         NULL,    NULL,          6,             2),
    ('Third Place Group A/B/C',   NULL,    NULL,          7,             2),
    ('Third Place Group D/E/F',   NULL,    NULL,          8,             2),
    ('Third Place Group A/D/E/F', NULL,    NULL,          9,             2),
    ('Third Place Group A/B/C/D', NULL,    NULL,          10,            2),
    ('Winner R16 1',              NULL,    NULL,          NULL,          3),
    ('Winner R16 2',              NULL,    NULL,          NULL,          3),
    ('Winner R16 3',              NULL,    NULL,          NULL,          3),
    ('Winner R16 4',              NULL,    NULL,          NULL,          3),
    ('Winner R16 5',              NULL,    NULL,          NULL,          3),
    ('Winner R16 6',              NULL,    NULL,          NULL,          3),
    ('Winner R16 7',              NULL,    NULL,          NULL,          3),
    ('Winner R16 8',              NULL,    NULL,          NULL,          3),
    ('Winner Quarter-Final 1',    NULL,    NULL,          NULL,          4),
    ('Winner Quarter-Final 2',    NULL,    NULL,          NULL,          4),
    ('Winner Quarter-Final 3',    NULL,    NULL,          NULL,          4),
    ('Winner Quarter-Final 4',    NULL,    NULL,          NULL,          4),
    ('Winner Semi-Final 1',       NULL,    NULL,          NULL,          5),
    ('Winner Semi-Final 2',       NULL,    NULL,          NULL,          5);

INSERT INTO match
    (date, kick_off, venue_id, home_team_id, away_team_id, home_team_points, away_team_points, result_posted_by, result_posted_on, stage_id, broadcaster_id) VALUES
    ('2024-06-14', '20:00:00', 2, 1, 2, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-15', '14:00:00', 2, 3, 4, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-15', '17:00:00', 2, 5, 6, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-15', '20:00:00', 10, 7, 8, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-16', '14:00:00', 2, 13, 14, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-16', '17:00:00', 2, 9, 10, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-16', '20:00:00', 2, 11, 12, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-17', '14:00:00', 2, 19, 20, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-17', '17:00:00', 5, 17, 18, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-17', '20:00:00', 2, 15, 16, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-18', '17:00:00', 10, 21, 22, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-18', '20:00:00', 2, 23, 24, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-19', '14:00:00', 2, 6, 8, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-19', '17:00:00', 2, 1, 3, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-19', '20:00:00', 2, 2, 4, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-20', '14:00:00', 2, 9, 11, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-20', '17:00:00', 5, 10, 12, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-20', '20:00:00', 2, 5, 7, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-21', '14:00:00', 2, 18, 20, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-21', '17:00:00', 2, 13, 15, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-21', '20:00:00', 2, 14, 16, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-22', '14:00:00', 2, 22, 24, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-22', '17:00:00', 10, 21, 23, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-22', '20:00:00', 2, 17, 19, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-23', '20:00:00', 5, 4, 1, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-23', '20:00:00', 2, 2, 3, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-24', '20:00:00', 2, 6, 7, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-24', '20:00:00', 2, 8, 5, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-25', '17:00:00', 2, 14, 15, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-25', '17:00:00', 10, 16, 13, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-25', '20:00:00', 2, 12, 9, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-25', '20:00:00', 2, 10, 11, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-26', '17:00:00', 5, 18, 19, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-26', '17:00:00', 2, 20, 17, NULL, NULL, NULL, NULL, 1, 1),
    ('2024-06-26', '20:00:00', 2, 24, 21, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-26', '20:00:00', 2, 22, 23, NULL, NULL, NULL, NULL, 1, 2),
    ('2024-06-29', '17:00:00', 2, 31, 32, NULL, NULL, NULL, NULL, 2, 1),
    ('2024-06-29', '20:00:00', 10, 25, 33, NULL, NULL, NULL, NULL, 2, 2),
    ('2024-06-30', '17:00:00', 2, 27, 38, NULL, NULL, NULL, NULL, 2, 1),
    ('2024-06-30', '20:00:00', 2, 26, 39, NULL, NULL, NULL, NULL, 2, 2),
    ('2024-07-01', '17:00:00', 2, 34, 35, NULL, NULL, NULL, NULL, 2, 1),
    ('2024-07-01', '20:00:00', 5, 30, 37, NULL, NULL, NULL, NULL, 2, 2),
    ('2024-07-02', '17:00:00', 2, 29, 40, NULL, NULL, NULL, NULL, 2, 1),
    ('2024-07-02', '20:00:00', 2, 28, 36, NULL, NULL, NULL, NULL, 2, 2),
    ('2024-07-05', '17:00:00', 2, 43, 41, NULL, NULL, NULL, NULL, 3, 3),
    ('2024-07-05', '20:00:00', 2, 45, 46, NULL, NULL, NULL, NULL, 3, 3),
    ('2024-07-06', '17:00:00', 2, 44, 42, NULL, NULL, NULL, NULL, 3, 3),
    ('2024-07-06', '20:00:00', 2, 47, 48, NULL, NULL, NULL, NULL, 3, 3),
    ('2024-07-09', '20:00:00', 2, 49, 50, NULL, NULL, NULL, NULL, 4, 3),
    ('2024-07-10', '20:00:00', 10, 51, 52, NULL, NULL, NULL, NULL, 4, 3),
    ('2024-07-14', '20:00:00', 2, 53, 54, NULL, NULL, NULL, NULL, 5, 1);

-- Fill these in after we have both matches and tournament roles for the foreign keys
UPDATE tournament_role SET from_match_id = 37 WHERE tournament_role_id = 41; -- name = 'Winner R16 1'
UPDATE tournament_role SET from_match_id = 38 WHERE tournament_role_id = 42; -- name = 'Winner R16 2'
UPDATE tournament_role SET from_match_id = 39 WHERE tournament_role_id = 43; -- name = 'Winner R16 3'
UPDATE tournament_role SET from_match_id = 40 WHERE tournament_role_id = 44; -- name = 'Winner R16 4'
UPDATE tournament_role SET from_match_id = 41 WHERE tournament_role_id = 45; -- name = 'Winner R16 5'
UPDATE tournament_role SET from_match_id = 42 WHERE tournament_role_id = 46; -- name = 'Winner R16 6'
UPDATE tournament_role SET from_match_id = 43 WHERE tournament_role_id = 47; -- name = 'Winner R16 7'
UPDATE tournament_role SET from_match_id = 44 WHERE tournament_role_id = 48; -- name = 'Winner R16 8'
UPDATE tournament_role SET from_match_id = 45 WHERE tournament_role_id = 49; -- name = 'Winner Quarter-Final 1'
UPDATE tournament_role SET from_match_id = 46 WHERE tournament_role_id = 50; -- name = 'Winner Quarter-Final 2'
UPDATE tournament_role SET from_match_id = 47 WHERE tournament_role_id = 51; -- name = 'Winner Quarter-Final 3'
UPDATE tournament_role SET from_match_id = 48 WHERE tournament_role_id = 52; -- name = 'Winner Quarter-Final 4'
UPDATE tournament_role SET from_match_id = 49 WHERE tournament_role_id = 53; -- name = 'Winner Semi-Final 1'
UPDATE tournament_role SET from_match_id = 50 WHERE tournament_role_id = 54; -- name = 'Winner Semi-Final 2'

INSERT INTO emails (match_id, predictions_sent, results_sent) VALUES
    (1, FALSE, FALSE),
    (2, FALSE, FALSE),
    (3, FALSE, FALSE),
    (4, FALSE, FALSE),
    (5, FALSE, FALSE),
    (6, FALSE, FALSE),
    (7, FALSE, FALSE),
    (8, FALSE, FALSE),
    (9, FALSE, FALSE),
    (10, FALSE, FALSE),
    (11, FALSE, FALSE),
    (12, FALSE, FALSE),
    (13, FALSE, FALSE),
    (14, FALSE, FALSE),
    (15, FALSE, FALSE),
    (16, FALSE, FALSE),
    (17, FALSE, FALSE),
    (18, FALSE, FALSE),
    (19, FALSE, FALSE),
    (20, FALSE, FALSE),
    (21, FALSE, FALSE),
    (22, FALSE, FALSE),
    (23, FALSE, FALSE),
    (24, FALSE, FALSE),
    (25, FALSE, FALSE),
    (26, FALSE, FALSE),
    (27, FALSE, FALSE),
    (28, FALSE, FALSE),
    (29, FALSE, FALSE),
    (30, FALSE, FALSE),
    (31, FALSE, FALSE),
    (32, FALSE, FALSE),
    (33, FALSE, FALSE),
    (34, FALSE, FALSE),
    (35, FALSE, FALSE),
    (36, FALSE, FALSE),
    (37, FALSE, FALSE),
    (38, FALSE, FALSE),
    (39, FALSE, FALSE),
    (40, FALSE, FALSE),
    (41, FALSE, FALSE),
    (42, FALSE, FALSE),
    (43, FALSE, FALSE),
    (44, FALSE, FALSE),
    (45, FALSE, FALSE),
    (46, FALSE, FALSE),
    (47, FALSE, FALSE),
    (48, FALSE, FALSE),
    (49, FALSE, FALSE),
    (50, FALSE, FALSE),
    (51, FALSE, FALSE);

INSERT INTO scoring_system (name) VALUES
    ('Official'),
    ('AutoQuiz');
