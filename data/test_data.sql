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
    ('Binary Boy', 'richard.morrison3@googlemail.com',     '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('DTM',        'dan.smith@citi.com',                   '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Will Mac',   'will.macadie@gmail.com',               '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Kov',        'doctorkov@googlemail.com',             '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Sammie',     'sarahkowenicki@hotmail.com',           '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Uwe',        'markrusling@hotmail.com',              '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Clare Mac',  'clare@macadie.co.uk',                  '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Tom Mac',    'tom_macadie@hotmail.com',              '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Fi Mac',     'fknox1@hotmail.com',                   '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Matt',       'mattmargrett@gmail.com',               '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('G.Mozz',     'gmorrison100@gmail.com',               '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Haller',     'james.russell.hall@gmail.com',         '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Archie',     'archie.bland@theguardian.com',         '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Ben',        'ben@benhart.co.uk',                    '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Ollie',      'oliver.peck@rocketmail.com',           '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('David',      'david@davidhart.co.uk',                '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Coups',      'pcoupar@hotmail.com',                  '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Peck',       'tompeck1000@gmail.com',                '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Gen',        'gen.smith@gmail.com',                  '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Diego',      'martin.ayers@talk21.com',              '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Ross',       'rceallen@gmail.com',                   '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Mark S',     'maspinks@hotmail.com',                 '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Mond',       'desmcewan@hotmail.com',                '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Lottie',     'happylottie@hotmail.com',              '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Sven',       'jari.stehn@gmail.com',                 '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Lady Peck',  'alice.jones@inews.co.uk',              '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('galsnakes',  'Sam.Gallagher@progressivecontent.com', '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Jonny',      'jonnyzpearson@gmail.com',              '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Manon',      'manoncornu@live.fr',                   '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Rosa',       'rosama68@hotmail.com',                 '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6');

INSERT INTO role (name) VALUES
    ('Admin'),
    ('Mr Mean'),
    ('Mr Median'),
    ('Mr Mode');

INSERT INTO user_role (user_id, role_id) VALUES
    (1, 2),
    (2, 3),
    (3, 4),
    (4, 1);

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
    (CURRENT_DATE - INTERVAL '4 DAYS', '20:00:00', 2, 1, 2, 6, 3, NULL, NULL, 1, 2),
    (CURRENT_DATE - INTERVAL '3 DAYS', '14:00:00', 2, 3, 4, 4, 5, NULL, NULL, 1, 2),
    (CURRENT_DATE - INTERVAL '3 DAYS', '17:00:00', 2, 5, 6, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE - INTERVAL '3 DAYS', '20:00:00', 10, 7, 8, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE - INTERVAL '2 DAYS', '14:00:00', 2, 13, 14, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE - INTERVAL '2 DAYS', '17:00:00', 2, 9, 10, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE - INTERVAL '2 DAYS', '20:00:00', 2, 11, 12, 61, 62, NULL, NULL, 1, 1),
    (CURRENT_DATE - INTERVAL '1 DAY', '14:00:00', 2, 19, 20, 63, 64, NULL, NULL, 1, 1),
    (CURRENT_DATE, split_part((CURRENT_TIME - INTERVAL '5 MINUTES')::text, '.', 1)::time, 5, 17, 18, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE, split_part((CURRENT_TIME + INTERVAL '15 MINUTES')::text, '.', 1)::time, 5, 15, 16, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE, split_part((CURRENT_TIME + INTERVAL '35 MINUTES')::text, '.', 1)::time, 5, 21, 22, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE + INTERVAL '2 DAYS', '20:00:00', 2, 23, 24, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '3 DAYS', '14:00:00', 2, 6, 8, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE + INTERVAL '3 DAYS', '17:00:00', 2, 1, 3, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '3 DAYS', '20:00:00', 2, 2, 4, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '4 DAYS', '14:00:00', 2, 9, 11, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE + INTERVAL '4 DAYS', '17:00:00', 5, 10, 12, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '4 DAYS', '20:00:00', 2, 5, 7, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE + INTERVAL '5 DAYS', '14:00:00', 2, 18, 20, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '5 DAYS', '17:00:00', 2, 13, 15, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE + INTERVAL '5 DAYS', '20:00:00', 2, 14, 16, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '6 DAYS', '14:00:00', 2, 22, 24, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '6 DAYS', '17:00:00', 10, 21, 23, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE + INTERVAL '6 DAYS', '20:00:00', 2, 17, 19, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE + INTERVAL '7 DAYS', '20:00:00', 5, 4, 1, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '7 DAYS', '20:00:00', 2, 2, 3, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '8 DAYS', '20:00:00', 2, 6, 7, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '8 DAYS', '20:00:00', 2, 8, 5, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '9 DAYS', '17:00:00', 2, 14, 15, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '9 DAYS', '17:00:00', 10, 16, 13, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '9 DAYS', '20:00:00', 2, 12, 9, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE + INTERVAL '9 DAYS', '20:00:00', 2, 10, 11, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE + INTERVAL '10 DAYS', '17:00:00', 5, 18, 19, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '10 DAYS', '17:00:00', 2, 20, 17, NULL, NULL, NULL, NULL, 1, 1),
    (CURRENT_DATE + INTERVAL '10 DAYS', '20:00:00', 2, 24, 21, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE + INTERVAL '10 DAYS', '20:00:00', 2, 22, 23, NULL, NULL, NULL, NULL, 1, 2),
    (CURRENT_DATE + INTERVAL '13 DAYS', '17:00:00', 2, 31, 32, NULL, NULL, NULL, NULL, 2, 1),
    (CURRENT_DATE + INTERVAL '13 DAYS', '20:00:00', 10, 25, 33, NULL, NULL, NULL, NULL, 2, 2),
    (CURRENT_DATE + INTERVAL '14 DAYS', '17:00:00', 2, 27, 38, NULL, NULL, NULL, NULL, 2, 1),
    (CURRENT_DATE + INTERVAL '14 DAYS', '20:00:00', 2, 26, 39, NULL, NULL, NULL, NULL, 2, 2),
    (CURRENT_DATE + INTERVAL '15 DAYS', '17:00:00', 2, 34, 35, NULL, NULL, NULL, NULL, 2, 1),
    (CURRENT_DATE + INTERVAL '15 DAYS', '20:00:00', 5, 30, 37, NULL, NULL, NULL, NULL, 2, 2),
    (CURRENT_DATE + INTERVAL '16 DAYS', '17:00:00', 2, 29, 40, NULL, NULL, NULL, NULL, 2, 1),
    (CURRENT_DATE + INTERVAL '16 DAYS', '20:00:00', 2, 28, 36, NULL, NULL, NULL, NULL, 2, 2),
    (CURRENT_DATE + INTERVAL '18 DAYS', '17:00:00', 2, 43, 41, NULL, NULL, NULL, NULL, 3, 3),
    (CURRENT_DATE + INTERVAL '18 DAYS', '20:00:00', 2, 45, 46, NULL, NULL, NULL, NULL, 3, 3),
    (CURRENT_DATE + INTERVAL '19 DAYS', '17:00:00', 2, 44, 42, NULL, NULL, NULL, NULL, 3, 3),
    (CURRENT_DATE + INTERVAL '19 DAYS', '20:00:00', 2, 47, 48, NULL, NULL, NULL, NULL, 3, 3),
    (CURRENT_DATE + INTERVAL '21 DAYS', '20:00:00', 2, 49, 50, NULL, NULL, NULL, NULL, 4, 3),
    (CURRENT_DATE + INTERVAL '22 DAYS', '20:00:00', 10, 51, 52, NULL, NULL, NULL, NULL, 4, 3),
    (CURRENT_DATE + INTERVAL '26 DAYS', '20:00:00', 2, 53, 54, NULL, NULL, NULL, NULL, 5, 1);

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

INSERT INTO scoring_system (name) VALUES
    ('Official'),
    ('AutoQuiz');

INSERT INTO prediction (user_id, match_id, home_team_points, away_team_points, date_added) VALUES
    (11, 11, 77, 78, '2022-06-12 16:45:15'),
    (4, 12, 88, 89, '2022-06-13 11:45:15'),
    (11, 6, 71, 72, '2022-06-12 16:45:15'),
    (4, 6, 81, 82, '2022-06-13 11:45:15'),
    (11, 8, 73, 74, '2022-06-12 16:45:15'),
    (4, 8, 83, 84, '2022-06-13 11:45:15'),
    (11, 7, 6, 6, '2022-06-12 16:45:15'),
    (4, 7, 4, 2, '2022-06-13 11:45:15'),
    (5, 2, 2, 0, '2022-06-13 11:45:15'),
    (6, 2, 1, 4, '2022-06-13 11:45:15'),
    (7, 2, 0, 2, '2022-06-13 11:45:15'),
    (8, 2, 2, 1, '2022-06-13 11:45:15'),
    (9, 2, 2, 1, '2022-06-13 11:45:15'),
    (10, 2, 1, 0, '2022-06-13 11:45:15'),
    (12, 2, 2, 0, '2022-06-13 11:45:15'),
    (5, 3, 3, 20, '2022-06-13 11:45:15'),
    (6, 3, 1, 0, '2022-06-13 11:45:15'),
    (7, 3, 1, 0, '2022-06-13 11:45:15'),
    (8, 3, 1, 1, '2022-06-13 11:45:15'),
    (9, 3, 1, 0, '2022-06-13 11:45:15'),
    (10, 3, 2, 2, '2022-06-13 11:45:15'),
    (12, 3, 2, 4, '2022-06-13 11:45:15'),
    (11, 51, 6, 6, '2022-06-12 16:45:15');

INSERT INTO points (prediction_id, scoring_system_id, result_points, score_points, total_points) VALUES
    (7, 1, 1, 2, 3),
    (8, 1, 1, 0, 1),
    (7, 2, 2, 4, 6),
    (8, 2, 2, 0, 2);
