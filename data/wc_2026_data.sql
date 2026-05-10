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
    ('Mr. Mean',   'mrmean@julianrimet.com',    '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Mr. Median', 'mrmedian@julianrimet.com',  '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Mr. Mode',   'mrmode@julianrimet.com',    '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Maccas',     'j.macadie@ttg.co.uk',       '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6'),
    ('Clare Mac',  'clare@macadie.co.uk',       '$2a$12$bEpZUdqQkgZpNe2wKL3vkO1xsCJzjTDNwolKVSMpKHMhtV6xm4vD6');

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
    ('ITV 4'),
    ('BBC & ITV'),
    ('TBD');

INSERT INTO venue
    (name,                     city,           capacity) VALUES
    ('Estadio Azteca',         'Mexico City',  83000), -- 1
    ('Estadio Akron',          'Guadalajara',  48000), -- 2
    ('BMO Field',              'Toronto',      45000), -- 3
    ('SoFi Stadium',           'Los Angeles',  70000), -- 4
    ('Gillette Stadium',       'Boston',       65000), -- 5
    ('BC Place',               'Vancouver',    54000), -- 6
    ('MetLife Stadium',        'New York',     82500), -- 7
    ('Levi''s Stadium',        'San Fransisco',71000), -- 8
    ('Lincoln Financial Field','Philadelphia', 69000), -- 9
    ('NRG Stadium',            'Houston',      72000), -- 10
    ('AT&T Stadium',           'Dallas',       94000), -- 11
    ('Estadio BBVA',           'Monterrey',    53500), -- 12
    ('Hard Rock Stadium',      'Miami',        65000), -- 13
    ('Mercedes-Benz Stadium',  'Atlanta',      75000), -- 14
    ('Lumen Field',            'Seattle',      69000), -- 15
    ('Arrowhead Stadium',      'Kansas City',  73000); -- 16


INSERT INTO stage (name) VALUES
    ('Group Stages'), -- 1
    ('Round of 32'), -- 2
    ('Round of 16'), -- 3
    ('Quarter Finals'), -- 4
    ('Semi Finals'), -- 5
    ('Third Fourth Place Play-off'), -- 6
    ('Final'); -- 7

INSERT INTO base_group (name) VALUES
    ('A'),
    ('B'),
    ('C'),
    ('D'),
    ('E'),
    ('F'),
    ('G'),
    ('H'),
    ('I'),
    ('J'),
    ('K'),
    ('L');

INSERT INTO meta_group (name) VALUES
    ('A'), -- 1
    ('B'), -- 2
    ('C'), -- 3
    ('D'), -- 4
    ('E'), -- 5
    ('F'), -- 6
    ('G'), -- 7
    ('H'), -- 8
    ('I'), -- 9
    ('J'), -- 10
    ('K'), -- 11
    ('L'), -- 12
    ('A/B/C/D/F'), -- 13,
    ('C/D/F/G/H'), -- 14
    ('C/E/F/H/I'), -- 15
    ('E/H/I/J/K'), -- 16
    ('B/E/F/I/J'), -- 17
    ('A/E/H/I/J'), -- 18
    ('E/F/G/I/J'), -- 19
    ('D/E/I/J/L'); -- 20

INSERT INTO meta_group_map (meta_group_id, group_id) VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (6, 6),
    (7, 7),
    (8, 8),
    (9, 9),
    (10, 10),
    (11, 11),
    (12, 12),
    (13, 1),
    (13, 2),
    (13, 3),
    (13, 4),
    (13, 6),
    (14, 3),
    (14, 4),
    (14, 6),
    (14, 7),
    (14, 8),
    (15, 3),
    (15, 5),
    (15, 6),
    (15, 8),
    (15, 9),
    (16, 5),
    (16, 8),
    (16, 9),
    (16, 10),
    (16, 11),
    (17, 2),
    (17, 5),
    (17, 6),
    (17, 9),
    (17, 10),
    (18, 1),
    (18, 5),
    (18, 8),
    (18, 9),
    (18, 10),
    (19, 5),
    (19, 6),
    (19, 7),
    (19, 9),
    (19, 10),
    (20, 4),
    (20, 5),
    (20, 9),
    (20, 10),
    (20, 12);

INSERT INTO team (name, short_name) VALUES
    ('Mexico',                 'MEX'), -- 1, Group A
    ('South Africa',           'RSA'), -- 2, Group A
    ('South Korea',            'KOR'), -- 3, Group A
    ('Czechia',                'CZE'), -- 4, Group A
    ('Canada',                 'CAN'), -- 5, Group B
    ('Bosnia and Herzegovina', 'BIH'), -- 6, Group B
    ('Qatar',                  'QAT'), -- 7, Group B
    ('Switzerland',            'SUI'), -- 8, Group B
    ('Brazil',                 'BRA'), -- 9, Group C
    ('Morocco',                'MAR'), -- 10, Group C
    ('Haiti',                  'HAI'), -- 11, Group C
    ('Scotland',               'SCO'), -- 12, Group C
    ('USA',                    'USA'), -- 13, Group D
    ('Paraguay',               'PAR'), -- 14, Group D
    ('Australia',              'AUS'), -- 15, Group D
    ('Turkey',                 'TUR'), -- 16, Group D
    ('Germany',                'GER'), -- 17, Group E
    ('Curaçao',                'CUW'), -- 18, Group E
    ('Ivory Coast',            'CIV'), -- 19, Group E
    ('Ecuador',                'ECU'), -- 20, Group E
    ('Netherlands',            'NED'), -- 21, Group F
    ('Japan',                  'JPN'), -- 22, Group F
    ('Sweden',                 'SWE'), -- 23, Group F
    ('Tunisia',                'TUN'), -- 24, Group F
    ('Belgium',                'BEL'), -- 25, Group G
    ('Egypt',                  'EGY'), -- 26, Group G
    ('Iran',                   'IRN'), -- 27, Group G
    ('New Zealand',            'NZL'), -- 28, Group G
    ('Spain',                  'ESP'), -- 29, Group H
    ('Cape Verde',             'CPV'), -- 30, Group H
    ('Saudi Arabia',           'KSA'), -- 31, Group H
    ('Uruguay',                'URU'), -- 32, Group H
    ('France',                 'FRA'), -- 33, Group I
    ('Senegal',                'SEN'), -- 34, Group I
    ('Iraq',                   'IRQ'), -- 35, Group I
    ('Norway',                 'NOR'), -- 36, Group I
    ('Argentina',              'ARG'), -- 37, Group J
    ('Algeria',                'ALG'), -- 38, Group J
    ('Austria',                'AUT'), -- 39, Group J
    ('Jordan',                 'JOR'), -- 40, Group J
    ('Portugal',               'POR'), -- 41, Group K
    ('DR Congo',               'COD'), -- 42, Group K
    ('Uzbekistan',             'UZB'), -- 43, Group K
    ('Colombia',               'COL'), -- 44, Group K
    ('England',                'ENG'), -- 45, Group L
    ('Croatia',                'CRO'), -- 46, Group L
    ('Ghana',                  'GHA'), -- 47, Group L
    ('Panama',                 'PAN'); -- 48, Group L

INSERT INTO tournament_role
    (name,                  team_id, from_match_id, from_group_id, stage_id) VALUES
    ('Group A Team 1',            1,          NULL,             1,        1), -- 1
    ('Group A Team 2',            2,          NULL,             1,        1), -- 2
    ('Group A Team 3',            3,          NULL,             1,        1), -- 3
    ('Group A Team 4',            4,          NULL,             1,        1), -- 4
    ('Group B Team 1',            5,          NULL,             2,        1), -- 5
    ('Group B Team 2',            6,          NULL,             2,        1), -- 6
    ('Group B Team 3',            7,          NULL,             2,        1), -- 7
    ('Group B Team 4',            8,          NULL,             2,        1), -- 8
    ('Group C Team 1',            9,          NULL,             3,        1), -- 9
    ('Group C Team 2',           10,          NULL,             3,        1), -- 10
    ('Group C Team 3',           11,          NULL,             3,        1), -- 11
    ('Group C Team 4',           12,          NULL,             3,        1), -- 12
    ('Group D Team 1',           13,          NULL,             4,        1), -- 13
    ('Group D Team 2',           14,          NULL,             4,        1), -- 14
    ('Group D Team 3',           15,          NULL,             4,        1), -- 15
    ('Group D Team 4',           16,          NULL,             4,        1), -- 16
    ('Group E Team 1',           17,          NULL,             5,        1), -- 17
    ('Group E Team 2',           18,          NULL,             5,        1), -- 18
    ('Group E Team 3',           19,          NULL,             5,        1), -- 19
    ('Group E Team 4',           20,          NULL,             5,        1), -- 20
    ('Group F Team 1',           21,          NULL,             6,        1), -- 21
    ('Group F Team 2',           22,          NULL,             6,        1), -- 22
    ('Group F Team 3',           23,          NULL,             6,        1), -- 23
    ('Group F Team 4',           24,          NULL,             6,        1), -- 24
    ('Group G Team 1',           25,          NULL,             7,        1), -- 25
    ('Group G Team 2',           26,          NULL,             7,        1), -- 26
    ('Group G Team 3',           27,          NULL,             7,        1), -- 27
    ('Group G Team 4',           28,          NULL,             7,        1), -- 28
    ('Group H Team 1',           29,          NULL,             8,        1), -- 29
    ('Group H Team 2',           30,          NULL,             8,        1), -- 30
    ('Group H Team 3',           31,          NULL,             8,        1), -- 31
    ('Group H Team 4',           32,          NULL,             8,        1), -- 32
    ('Group I Team 1',           33,          NULL,             9,        1), -- 33
    ('Group I Team 2',           34,          NULL,             9,        1), -- 34
    ('Group I Team 3',           35,          NULL,             9,        1), -- 35
    ('Group I Team 4',           36,          NULL,             9,        1), -- 36
    ('Group J Team 1',           37,          NULL,            10,        1), -- 37
    ('Group J Team 2',           38,          NULL,            10,        1), -- 38
    ('Group J Team 3',           39,          NULL,            10,        1), -- 39
    ('Group J Team 4',           40,          NULL,            10,        1), -- 40
    ('Group K Team 1',           41,          NULL,            11,        1), -- 41
    ('Group K Team 2',           42,          NULL,            11,        1), -- 42
    ('Group K Team 3',           43,          NULL,            11,        1), -- 43
    ('Group K Team 4',           44,          NULL,            11,        1), -- 44
    ('Group L Team 1',           45,          NULL,            12,        1), -- 45
    ('Group L Team 2',           46,          NULL,            12,        1), -- 46
    ('Group L Team 3',           47,          NULL,            12,        1), -- 47
    ('Group L Team 4',           48,          NULL,            12,        1), -- 48
    ('Winner Group A',         NULL,          NULL,             1,        2), -- 49
    ('Runner-Up Group A',      NULL,          NULL,             1,        2), -- 50
    ('Winner Group B',         NULL,          NULL,             2,        2), -- 51
    ('Runner-Up Group B',      NULL,          NULL,             2,        2), -- 52
    ('Winner Group C',         NULL,          NULL,             3,        2), -- 53
    ('Runner-Up Group C',      NULL,          NULL,             3,        2), -- 54
    ('Winner Group D',         NULL,          NULL,             4,        2), -- 55
    ('Runner-Up Group D',      NULL,          NULL,             4,        2), -- 56
    ('Winner Group E',         NULL,          NULL,             5,        2), -- 57
    ('Runner-Up Group E',      NULL,          NULL,             5,        2), -- 58
    ('Winner Group F',         NULL,          NULL,             6,        2), -- 59
    ('Runner-Up Group F',      NULL,          NULL,             6,        2), -- 60
    ('Winner Group G',         NULL,          NULL,             7,        2), -- 61
    ('Runner-Up Group G',      NULL,          NULL,             7,        2), -- 62
    ('Winner Group H',         NULL,          NULL,             8,        2), -- 63
    ('Runner-Up Group H',      NULL,          NULL,             8,        2), -- 64
    ('Winner Group I',         NULL,          NULL,             9,        2), -- 65
    ('Runner-Up Group I',      NULL,          NULL,             9,        2), -- 66
    ('Winner Group J',         NULL,          NULL,            10,        2), -- 67
    ('Runner-Up Group J',      NULL,          NULL,            10,        2), -- 68
    ('Winner Group K',         NULL,          NULL,            11,        2), -- 69
    ('Runner-Up Group K',      NULL,          NULL,            11,        2), -- 70
    ('Winner Group L',         NULL,          NULL,            12,        2), -- 71
    ('Runner-Up Group L',      NULL,          NULL,            12,        2), -- 72
    ('3rd Group A/B/C/D/F',    NULL,          NULL,            13,        2), -- 73
    ('3rd Group C/D/F/G/H',    NULL,          NULL,            14,        2), -- 74
    ('3rd Group C/E/F/H/I',    NULL,          NULL,            15,        2), -- 75
    ('3rd Group E/H/I/J/K',    NULL,          NULL,            16,        2), -- 76
    ('3rd Group B/E/F/I/J',    NULL,          NULL,            17,        2), -- 77
    ('3rd Group A/E/H/I/J',    NULL,          NULL,            18,        2), -- 78
    ('3rd Group E/F/G/I/J',    NULL,          NULL,            19,        2), -- 79
    ('3rd Group D/E/I/J/L',    NULL,          NULL,            20,        2), -- 80
    ('Winner R32 1',           NULL,          NULL,          NULL,        3), -- 81
    ('Winner R32 2',           NULL,          NULL,          NULL,        3), -- 82
    ('Winner R32 3',           NULL,          NULL,          NULL,        3), -- 83
    ('Winner R32 4',           NULL,          NULL,          NULL,        3), -- 84
    ('Winner R32 5',           NULL,          NULL,          NULL,        3), -- 85
    ('Winner R32 6',           NULL,          NULL,          NULL,        3), -- 86
    ('Winner R32 7',           NULL,          NULL,          NULL,        3), -- 87
    ('Winner R32 8',           NULL,          NULL,          NULL,        3), -- 88
    ('Winner R32 9',           NULL,          NULL,          NULL,        3), -- 89
    ('Winner R32 10',          NULL,          NULL,          NULL,        3), -- 90
    ('Winner R32 11',          NULL,          NULL,          NULL,        3), -- 91
    ('Winner R32 12',          NULL,          NULL,          NULL,        3), -- 92
    ('Winner R32 13',          NULL,          NULL,          NULL,        3), -- 93
    ('Winner R32 14',          NULL,          NULL,          NULL,        3), -- 94
    ('Winner R32 15',          NULL,          NULL,          NULL,        3), -- 95
    ('Winner R32 16',          NULL,          NULL,          NULL,        3), -- 96
    ('Winner R16 1',           NULL,          NULL,          NULL,        4), -- 97
    ('Winner R16 2',           NULL,          NULL,          NULL,        4), -- 98
    ('Winner R16 3',           NULL,          NULL,          NULL,        4), -- 99
    ('Winner R16 4',           NULL,          NULL,          NULL,        4), -- 100
    ('Winner R16 5',           NULL,          NULL,          NULL,        4), -- 101
    ('Winner R16 6',           NULL,          NULL,          NULL,        4), -- 102
    ('Winner R16 7',           NULL,          NULL,          NULL,        4), -- 103
    ('Winner R16 8',           NULL,          NULL,          NULL,        4), -- 104
    ('Winner Quarter-Final 1', NULL,          NULL,          NULL,        5), -- 105
    ('Winner Quarter-Final 2', NULL,          NULL,          NULL,        5), -- 106
    ('Winner Quarter-Final 3', NULL,          NULL,          NULL,        5), -- 107
    ('Winner Quarter-Final 4', NULL,          NULL,          NULL,        5), -- 108
    ('Loser Semi-Final 1',     NULL,          NULL,          NULL,        6), -- 109
    ('Loser Semi-Final 2',     NULL,          NULL,          NULL,        6), -- 110
    ('Winner Semi-Final 1',    NULL,          NULL,          NULL,        7), -- 111
    ('Winner Semi-Final 2',    NULL,          NULL,          NULL,        7); -- 112


INSERT INTO match
    (date,         kick_off,   venue_id, home_team_id, away_team_id, home_team_points, away_team_points, result_posted_by, result_posted_on, stage_id, broadcaster_id) VALUES
    ('2026-06-11', '20:00:00', 1,        1,            2,            NULL,             NULL,             NULL,             NULL,             1,        2), -- 1
    ('2026-06-12', '03:00:00', 2,        3,            4,            NULL,             NULL,             NULL,             NULL,             1,        2), -- 2
    ('2026-06-12', '20:00:00', 3,        5,            6,            NULL,             NULL,             NULL,             NULL,             1,        1), -- 3
    ('2026-06-13', '02:00:00', 4,        13,           14,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 4
    ('2026-06-14', '02:00:00', 5,        11,           12,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 5
    ('2026-06-14', '05:00:00', 6,        15,           16,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 6
    ('2026-06-13', '23:00:00', 7,        9,            10,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 7
    ('2026-06-13', '20:00:00', 8,        7,            8,            NULL,             NULL,             NULL,             NULL,             1,        2), -- 8
    ('2026-06-15', '00:00:00', 9,        19,           20,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 9
    ('2026-06-14', '18:00:00', 10,       17,           18,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 10
    ('2026-06-14', '21:00:00', 11,       21,           22,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 11
    ('2026-06-15', '03:00:00', 12,       23,           24,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 12
    ('2026-06-15', '23:00:00', 13,       31,           32,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 13
    ('2026-06-15', '17:00:00', 14,       29,           30,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 14
    ('2026-06-16', '02:00:00', 4,        27,           28,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 15
    ('2026-06-15', '20:00:00', 15,       25,           26,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 16
    ('2026-06-16', '20:00:00', 7,        33,           34,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 17
    ('2026-06-16', '23:00:00', 5,        35,           36,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 18
    ('2026-06-17', '02:00:00', 16,       37,           38,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 19
    ('2026-06-17', '05:00:00', 8,        39,           40,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 20
    ('2026-06-18', '00:00:00', 3,        47,           48,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 21
    ('2026-06-17', '21:00:00', 11,       45,           46,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 22
    ('2026-06-17', '18:00:00', 10,       41,           42,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 23
    ('2026-06-18', '03:00:00', 1,        43,           44,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 24
    ('2026-06-18', '17:00:00', 14,       4,            2,            NULL,             NULL,             NULL,             NULL,             1,        1), -- 25
    ('2026-06-18', '20:00:00', 4,        8,            6,            NULL,             NULL,             NULL,             NULL,             1,        2), -- 26
    ('2026-06-18', '23:00:00', 6,        5,            7,            NULL,             NULL,             NULL,             NULL,             1,        2), -- 27
    ('2026-06-19', '02:00:00', 2,        1,            3,            NULL,             NULL,             NULL,             NULL,             1,        1), -- 28
    ('2026-06-20', '01:30:00', 9,        9,            11,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 29
    ('2026-06-19', '23:00:00', 5,        12,           10,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 30
    ('2026-06-20', '04:00:00', 8,        16,           14,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 31
    ('2026-06-19', '20:00:00', 15,       13,           15,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 32
    ('2026-06-20', '21:00:00', 3,        17,           19,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 33
    ('2026-06-21', '01:00:00', 16,       20,           18,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 34
    ('2026-06-20', '18:00:00', 10,       21,           23,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 35
    ('2026-06-21', '05:00:00', 12,       24,           22,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 36
    ('2026-06-21', '23:00:00', 13,       32,           30,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 37
    ('2026-06-21', '17:00:00', 14,       29,           31,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 38
    ('2026-06-21', '20:00:00', 4,        25,           27,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 39
    ('2026-06-22', '02:00:00', 6,        28,           26,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 40
    ('2026-06-23', '01:00:00', 7,        36,           34,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 41
    ('2026-06-22', '22:00:00', 9,        33,           35,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 42
    ('2026-06-22', '18:00:00', 11,       37,           39,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 43
    ('2026-06-23', '04:00:00', 8,        40,           38,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 44
    ('2026-06-23', '21:00:00', 5,        45,           47,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 45
    ('2026-06-24', '00:00:00', 3,        48,           46,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 46
    ('2026-06-23', '18:00:00', 10,       41,           43,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 47
    ('2026-06-24', '03:00:00', 2,        44,           42,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 48
    ('2026-06-24', '23:00:00', 13,       12,           9,            NULL,             NULL,             NULL,             NULL,             1,        1), -- 49
    ('2026-06-24', '23:00:00', 14,       10,           11,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 50
    ('2026-06-24', '20:00:00', 6,        8,            5,            NULL,             NULL,             NULL,             NULL,             1,        2), -- 51
    ('2026-06-24', '20:00:00', 15,       6,            7,            NULL,             NULL,             NULL,             NULL,             1,        2), -- 52
    ('2026-06-25', '02:00:00', 1,        4,            1,            NULL,             NULL,             NULL,             NULL,             1,        1), -- 53
    ('2026-06-25', '02:00:00', 12,       2,            3,            NULL,             NULL,             NULL,             NULL,             1,        1), -- 54
    ('2026-06-25', '21:00:00', 9,        18,           19,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 55
    ('2026-06-25', '21:00:00', 7,        20,           17,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 56
    ('2026-06-26', '00:00:00', 11,       22,           23,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 57
    ('2026-06-26', '00:00:00', 16,       24,           21,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 58
    ('2026-06-26', '03:00:00', 4,        16,           13,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 59
    ('2026-06-26', '03:00:00', 8,        14,           15,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 60
    ('2026-06-26', '20:00:00', 5,        36,           33,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 61
    ('2026-06-26', '20:00:00', 3,        34,           35,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 62
    ('2026-06-27', '04:00:00', 15,       26,           27,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 63
    ('2026-06-27', '04:00:00', 6,        28,           25,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 64
    ('2026-06-27', '01:00:00', 10,       30,           31,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 65
    ('2026-06-27', '01:00:00', 2,        32,           29,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 66
    ('2026-06-27', '22:00:00', 7,        48,           45,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 67
    ('2026-06-27', '22:00:00', 9,        46,           47,           NULL,             NULL,             NULL,             NULL,             1,        2), -- 68
    ('2026-06-28', '03:00:00', 16,       38,           39,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 69
    ('2026-06-28', '03:00:00', 11,       40,           37,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 70
    ('2026-06-28', '00:30:00', 13,       44,           41,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 71
    ('2026-06-28', '00:30:00', 14,       42,           43,           NULL,             NULL,             NULL,             NULL,             1,        1), -- 72
    ('2026-06-28', '20:00:00', 4,        50,           52,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 73
    ('2026-06-29', '21:30:00', 5,        57,           73,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 74
    ('2026-06-30', '02:00:00', 12,       59,           54,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 75
    ('2026-06-29', '18:00:00', 10,       53,           60,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 76
    ('2026-06-30', '22:00:00', 7,        65,           74,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 77
    ('2026-06-30', '18:00:00', 11,       58,           66,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 78
    ('2026-07-01', '02:00:00', 1,        49,           75,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 79
    ('2026-07-01', '17:00:00', 14,       71,           76,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 80
    ('2026-07-02', '01:00:00', 8,        55,           77,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 81
    ('2026-07-01', '21:00:00', 15,       61,           78,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 82
    ('2026-07-03', '00:00:00', 3,        70,           72,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 83
    ('2026-07-02', '20:00:00', 4,        63,           68,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 84
    ('2026-07-03', '04:00:00', 6,        51,           79,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 85
    ('2026-07-03', '23:00:00', 13,       67,           64,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 86
    ('2026-07-04', '02:30:00', 16,       69,           80,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 87
    ('2026-07-03', '19:00:00', 11,       56,           62,           NULL,             NULL,             NULL,             NULL,             2,        5), -- 88
    ('2026-07-04', '22:00:00', 9,        82,           85,           NULL,             NULL,             NULL,             NULL,             3,        5), -- 89
    ('2026-07-04', '18:00:00', 10,       81,           83,           NULL,             NULL,             NULL,             NULL,             3,        5), -- 90
    ('2026-07-05', '21:00:00', 7,        84,           86,           NULL,             NULL,             NULL,             NULL,             3,        5), -- 91
    ('2026-07-06', '01:00:00', 1,        87,           88,           NULL,             NULL,             NULL,             NULL,             3,        5), -- 92
    ('2026-07-06', '20:00:00', 11,       91,           92,           NULL,             NULL,             NULL,             NULL,             3,        5), -- 93
    ('2026-07-07', '01:00:00', 15,       89,           90,           NULL,             NULL,             NULL,             NULL,             3,        5), -- 94
    ('2026-07-07', '17:00:00', 14,       94,           96,           NULL,             NULL,             NULL,             NULL,             3,        5), -- 95
    ('2026-07-07', '21:00:00', 6,        93,           95,           NULL,             NULL,             NULL,             NULL,             3,        5), -- 96
    ('2026-07-09', '21:00:00', 5,        97,           98,           NULL,             NULL,             NULL,             NULL,             4,        5), -- 97
    ('2026-07-10', '20:00:00', 4,        101,          102,          NULL,             NULL,             NULL,             NULL,             4,        5), -- 98
    ('2026-07-11', '22:00:00', 13,       99,           100,          NULL,             NULL,             NULL,             NULL,             4,        5), -- 99
    ('2026-07-12', '02:00:00', 16,       103,          104,          NULL,             NULL,             NULL,             NULL,             4,        5), -- 100
    ('2026-07-14', '20:00:00', 11,       105,          106,          NULL,             NULL,             NULL,             NULL,             5,        5), -- 101
    ('2026-07-15', '20:00:00', 14,       107,          108,          NULL,             NULL,             NULL,             NULL,             5,        5), -- 102
    ('2026-07-18', '22:00:00', 13,       109,          110,          NULL,             NULL,             NULL,             NULL,             6,        5), -- 103
    ('2026-07-19', '20:00:00', 7,        111,          112,          NULL,             NULL,             NULL,             NULL,             7,        4); -- 104


-- Put the from matches into tournament_role after match to avoid the FKs complaining
UPDATE tournament_role SET from_match_id = 73 WHERE tournament_role_id = 81; -- Winner R32 1
UPDATE tournament_role SET from_match_id = 74 WHERE tournament_role_id = 82; -- Winner R32 2
UPDATE tournament_role SET from_match_id = 75 WHERE tournament_role_id = 83; -- Winner R32 3
UPDATE tournament_role SET from_match_id = 76 WHERE tournament_role_id = 84; -- Winner R32 4
UPDATE tournament_role SET from_match_id = 77 WHERE tournament_role_id = 85; -- Winner R32 5
UPDATE tournament_role SET from_match_id = 78 WHERE tournament_role_id = 86; -- Winner R32 6
UPDATE tournament_role SET from_match_id = 79 WHERE tournament_role_id = 87; -- Winner R32 7
UPDATE tournament_role SET from_match_id = 80 WHERE tournament_role_id = 88; -- Winner R32 8
UPDATE tournament_role SET from_match_id = 81 WHERE tournament_role_id = 89; -- Winner R32 9
UPDATE tournament_role SET from_match_id = 82 WHERE tournament_role_id = 90; -- Winner R32 10
UPDATE tournament_role SET from_match_id = 83 WHERE tournament_role_id = 91; -- Winner R32 11
UPDATE tournament_role SET from_match_id = 84 WHERE tournament_role_id = 92; -- Winner R32 12
UPDATE tournament_role SET from_match_id = 85 WHERE tournament_role_id = 93; -- Winner R32 13
UPDATE tournament_role SET from_match_id = 86 WHERE tournament_role_id = 94; -- Winner R32 14
UPDATE tournament_role SET from_match_id = 87 WHERE tournament_role_id = 95; -- Winner R32 15
UPDATE tournament_role SET from_match_id = 88 WHERE tournament_role_id = 96; -- Winner R32 16
UPDATE tournament_role SET from_match_id = 89 WHERE tournament_role_id = 97; -- Winner R16 1
UPDATE tournament_role SET from_match_id = 90 WHERE tournament_role_id = 98; -- Winner R16 2
UPDATE tournament_role SET from_match_id = 91 WHERE tournament_role_id = 99; -- Winner R16 3
UPDATE tournament_role SET from_match_id = 92 WHERE tournament_role_id = 100; -- Winner R16 4
UPDATE tournament_role SET from_match_id = 93 WHERE tournament_role_id = 101; -- Winner R16 5
UPDATE tournament_role SET from_match_id = 94 WHERE tournament_role_id = 102; -- Winner R16 6
UPDATE tournament_role SET from_match_id = 95 WHERE tournament_role_id = 103; -- Winner R16 7
UPDATE tournament_role SET from_match_id = 96 WHERE tournament_role_id = 104; -- Winner R16 8
UPDATE tournament_role SET from_match_id = 97 WHERE tournament_role_id = 105; -- Winner Quarter-Final 1
UPDATE tournament_role SET from_match_id = 98 WHERE tournament_role_id = 106; -- Winner Quarter-Final 2
UPDATE tournament_role SET from_match_id = 99 WHERE tournament_role_id = 107; -- Winner Quarter-Final 3
UPDATE tournament_role SET from_match_id = 100 WHERE tournament_role_id = 108; -- Winner Quarter-Final 4
UPDATE tournament_role SET from_match_id = 101 WHERE tournament_role_id = 109; -- Loser Semi-Final 1
UPDATE tournament_role SET from_match_id = 102 WHERE tournament_role_id = 110; -- Loser Semi-Final 2
UPDATE tournament_role SET from_match_id = 101 WHERE tournament_role_id = 111; -- Winner Semi-Final 1
UPDATE tournament_role SET from_match_id = 102 WHERE tournament_role_id = 112; -- Winner Semi-Final 2


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
    (51, FALSE, FALSE),
    (52, FALSE, FALSE),
    (53, FALSE, FALSE),
    (54, FALSE, FALSE),
    (55, FALSE, FALSE),
    (56, FALSE, FALSE),
    (57, FALSE, FALSE),
    (58, FALSE, FALSE),
    (59, FALSE, FALSE),
    (60, FALSE, FALSE),
    (61, FALSE, FALSE),
    (62, FALSE, FALSE),
    (63, FALSE, FALSE),
    (64, FALSE, FALSE);


INSERT INTO scoring_system (name) VALUES
    ('Official'),
    ('AutoQuiz');
