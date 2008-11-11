--[[

Skillet: A tradeskill window replacement.
Copyright (c) 2007 Robert Clark <nogudnik@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

]]


local AceEvent = AceLibrary("AceEvent-2.0")
local PT
if AceLibrary:HasInstance("LibPeriodicTable-3.1") then
	PT = AceLibrary("LibPeriodicTable-3.1")
end

-- a table of tradeskills by id (lowest qualifying skill only)
local TradeSkillList = {
	2259,           -- alchemy
	2018,           -- blacksmithing
	7411,           -- enchanting 
	4036,           -- engineering
	45357,			-- inscription
	25229,          -- jewelcrafting
	2108,           -- leatherworking
--	2575,			-- mining (or smelting?)
	2656,           -- smelting (from mining)
	3908,           -- tailoring
	2550,           -- cooking
	3273,           -- first aid
--	2842,           -- poisons

	
--	5149, 			-- beast training (not supported, but i need to know the number)... err... or maybe i don't
}

local TradeSkillRecipeList = {
	[3908] = 
--	{ 3908,3909,3910,12180,26801,26798,26797,26790,51309 },
	{ 3908,3909,3910,2963,2387,2385,2389,2386,2392,2393,2394,2397,2395,2396,2964,2402,2399,2401,2403,2406,3839,3865,3840,3841,3842,3843,3844,3845,3847,3848,3849,3850,3851,3852,3854,3855,3856,3857,3858,3859,3860,3861,3862,3863,3864,3866,3868,3869,3870,3871,3872,3873,3914,3915,6521,3758,3755,3757,3813,6686,6688,6690,6692,6693,6695,7623,7624,7630,7629,7633,7636,7639,7643,7892,7893,8465,8467,8489,8483,8776,8758,8760,8762,8764,8766,8770,8772,8774,8778,8780,8782,8784,8786,8789,8791,8793,8795,8797,8799,8802,8804,12044,12045,12046,12047,12048,12049,12050,12052,12053,12055,12056,12059,12060,12061,12062,12063,12064,12065,12066,12067,12068,12069,12070,12071,12072,12073,12074,12075,12076,12077,12078,12079,12080,12081,12082,12083,12084,12085,12086,12087,12088,12089,12090,12091,12092,12093,12180,18401,18402,18403,18404,18406,18405,18407,18408,18409,18410,18411,18412,18415,18413,18414,18416,18417,18418,18419,18420,18421,18422,18423,18424,18434,18436,18437,18438,18439,18440,18441,18442,18444,18445,18446,18447,18448,18449,18450,18451,18452,18453,18454,18455,18456,18457,18458,18560,19435,20848,20849,21945,22759,22813,22866,22867,22868,22869,22870,22902,23662,23664,23663,23665,23666,23667,24093,24092,24091,24902,24903,24901,26085,26086,26087,26403,26407,26745,26746,26747,26749,26750,26751,26752,26753,26754,26755,26756,26757,26758,26759,26760,26761,26762,26763,26764,26765,26770,26771,26772,26773,26774,26775,26776,26777,26778,26779,26780,26781,26782,26783,26784,26801,26798,26797,26790,27658,27659,27660,27724,27725,28210,28208,28205,28207,28209,28481,28482,28480,31430,31431,31432,31433,31434,31435,31437,31438,31440,31441,31442,31443,31444,31448,31449,31450,31451,31452,31453,31454,31455,31456,31459,31460,31461,31373,36315,36317,36316,36318,36670,36672,36669,36667,36668,36665,36686,37873,37882,37883,37884,40021,40024,40023,40020,40060,41207,41208,41205,41206,44958,44950,46129,46131,46128,46130,49677,50194,50644,50647,51309,55642,55769,55777,55898,55899,55900,55902,55903,55904,56030,55906,55907,55908,55910,55911,55913,55901,55914,55921,55922,55919,55924,55925,55920,55923,55941,55943,55993,55994,55995,55996,55997,55998,55999,56000,56002,56001,56003,56004,56005,56006,56007,56008,56009,56010,56011,56014,56015,56017,56016,56018,56019,56020,56021,56022,56023,56024,56025,56026,56027,56028,56029,56031,56034,56039,56048,59390,59582,59583,59584,59585,59586,59587,59588,59589,60969,60971,60993,60994,60990 },


	[7411] = 
--	{ 7411,7412,7413,13920,28029,51313 },
	{ 7411,7412,7413,7418,7420,7421,7426,7428,7443,7454,7457,7748,7766,7771,7776,7779,7782,7786,7788,7745,7793,7795,7857,7859,7861,7863,7867,13262,13378,13380,13419,13421,13464,13485,13501,13503,13522,13529,13536,13538,13607,13612,13617,13620,13622,13626,13628,13631,13635,13637,13640,13642,13644,13646,13648,13653,13655,13657,13659,13661,13663,13687,13689,13693,13695,13698,13700,13702,13920,13746,13794,13815,13817,13822,13836,13841,13846,13858,13868,13882,13887,13890,13898,13905,13915,13917,13931,13933,13935,13937,13939,13941,13943,13945,13947,13948,14293,14807,14809,14810,15596,17181,17180,20008,20020,20014,20017,20009,20012,20024,20026,20016,20029,20015,20028,20051,20013,20023,20010,20030,20033,20036,20031,20011,20034,20025,20032,20035,21931,22749,22750,23799,23800,23801,23802,23803,23804,25072,25073,25074,25078,25079,25080,25081,25082,25083,25084,25086,25124,25125,25126,25127,25128,25129,25130,27837,28029,27899,27905,27906,27911,27913,27914,27917,27920,27924,27926,27927,27944,27945,27946,27947,27948,27950,27951,27954,27957,27958,27960,27961,27962,27967,27968,27972,27971,27975,27977,28004,28003,27984,27981,27982,28016,28019,28021,28022,32664,32665,32667,33990,33991,33992,33993,33994,33995,33996,33997,33999,34001,34002,34003,34004,34005,34006,34007,34008,34009,34010,28027,28028,42613,42615,42620,42974,44383,44483,44484,44488,44489,44492,44494,44497,44508,44500,44506,44509,44510,44528,44513,44524,44555,44556,44529,44575,44576,44584,44582,44589,44588,44590,44593,44591,44612,44592,44595,44598,44596,44616,44621,44623,44625,44630,44629,44631,44633,44635,44645,44636,45765,46578,46594,47051,47672,47898,47899,47901,51313,47766,60609,60616,60606,60618,60621,60623,60653,59636,60663,47900,60668,60619,60691,60707,60714,60692,60763,59621,59625,59619,60767 },

	[2108] = 
--	{ 2108,3104,3811,10656,10660,10658,10662,32549,51302 },
	{ 2108,2149,2152,2159,2881,3104,3811,3753,3756,3759,3760,3761,3762,3763,3764,3765,3766,3767,3768,3769,3770,3771,3772,3773,3774,3775,3776,3777,3778,3779,3816,3817,3818,3780,4097,4096,5244,6661,6702,6705,6703,6704,7126,7133,7135,7147,7149,7151,7153,7156,7955,7953,7954,8322,9058,9059,9060,9062,9064,9065,9068,9070,9072,9074,9145,9146,9147,9148,9149,9193,9194,9195,9196,9197,9198,9201,9202,9206,9207,9208,10482,10487,10490,10499,10507,10509,10511,10516,10518,10520,10525,10529,10531,10533,10542,10544,10546,10619,10621,10548,10550,10552,10630,10554,10556,10558,10560,10562,10564,10566,10568,10570,10572,10574,10632,10647,10650,10656,10660,10658,10662,14930,14932,19047,19058,19048,19049,19050,19051,19052,19053,19054,19055,19059,19060,19061,19062,19063,19064,19065,19066,19067,19068,19070,19071,19072,19073,19074,19075,19076,19077,19078,19079,19080,19081,19085,19084,19086,19082,19083,19089,19087,19088,19090,19094,19097,19095,19093,19091,19092,19100,19102,19101,19098,19107,19104,19106,19103,20648,20649,20650,20853,20854,20855,21943,22331,22711,22727,22815,22921,22922,22923,22926,22927,22928,23190,23399,23703,23705,23704,23706,23707,23708,23709,23710,24124,24125,24123,24122,24121,24655,24654,24846,24847,24848,24849,24850,24851,24940,24703,26279,28224,28222,28223,28221,28220,28219,28474,28473,28472,32454,32455,32456,32457,32458,32461,32462,32463,32464,32465,32466,32467,32468,32469,32470,32471,32472,32473,32478,32479,32480,32481,32482,32485,32487,32489,32488,32490,32493,32494,32495,32496,32497,32498,32499,32500,32501,32502,32503,32549,35530,35520,35521,35522,35523,35524,35527,35526,35525,35531,35528,35529,35534,35533,35532,35537,35536,35535,35538,35539,35540,35543,35544,35549,35555,35554,35557,35559,35558,35567,35562,35561,35564,35573,35572,35574,35563,35560,35568,35576,35577,35575,35582,35584,35580,35590,35591,35589,35587,35588,35585,36074,36076,36075,36079,36078,36077,36349,36351,36352,36353,36355,36357,36358,36359,39997,40001,40002,40006,40005,40003,40004,41161,41156,41163,41164,41157,41162,41158,41160,42546,42731,44344,44343,44359,44768,44770,44970,44953,45100,45117,46137,46138,46133,46134,46135,46139,46136,46132,50936,50962,50949,50955,50943,51302,50963,50948,50944,50945,50947,50946,51571,52733,55199,55243,57683,57699,57691,57694,57692,57690,57701,57696,60583,60584,50967,50965,51572,51570,51569,51568,50951,50950,50952,50953,50954,60599,60600,60601,60604,60605,50941,50939,50938,50942,50940,60607,60608,60611,60613,60620,50957,50959,50956,50961,50960,50958,60622,60624,60627,60629,60630,60631,60637,60640,50966,50964,50970,50971,60643,60645,60647,60649,60651,60652,60655,60658,60660,60665,60666,60669,60671,60697,60702,60703,60704,60705,60706,60711,60712,60715,60716,60718,60720,60721,60723,60725,60727,60728,60729,60730,60731,60732,60734,60735,60737,60743,60746,60747,60748,60749,60750,60751,60752,60754,60755,60756,60757,60758,60759,60761,60760,60998,60997,60996,61000,61002,60999,2153,2158,2160,2161,2162,2163,2164,2165,2167,2169,2168,2166 },

	[2550] = 
--	{ 2550,3102,3413,18260,33359,51296 },
	{ 2550,2538,2540,3102,3370,3371,3372,3373,3376,3377,3397,3398,3399,3400,3413,4094,6412,6413,6414,6415,6416,6417,6418,6419,6501,6500,6499,7213,7751,7752,7753,7754,7755,7827,7828,8238,8604,8607,9513,15935,15853,15855,15856,15861,15863,15865,15906,15910,15915,15933,818,18239,18238,18241,18240,18242,18243,18244,18245,18246,18247,18260,20626,20916,21144,21143,21175,22480,22761,24418,24801,25659,25704,25954,28267,33276,33277,33278,33279,33284,33285,33286,33287,33288,33289,33290,33291,33292,33293,33294,33295,33296,33359,36210,37836,38868,38867,42296,42302,42305,43707,43758,43761,43765,43779,45022,43772,13028,45695,46684,46688,51296,53056,45560,45561,45562,45563,45564,45565,45569,45566,57421,45549,45550,45551,45552,45553,45554,57423,45555,45556,45557,45558,45559,45567,45568,45571,45570,57433,57434,57435,57436,57437,57438,57439,57440,57441,57442,57443,58065,58512,58521,58523,58525,58527,58528,2539,2795,2541,2542,2543,2544,2545,2546,2547,2548,2549 },

	[25229] = 
--	{ 25229,25230,28894,28895,28897,51311 },
	{ 25229,25230,25278,25255,25280,25283,25284,25287,25305,25317,25318,25339,25320,25321,25323,25493,25490,25498,25610,25612,25613,25614,25615,25617,25618,25619,25620,25621,25622,26872,26873,26874,26875,26876,26878,26880,26881,26882,26883,26885,26887,26896,26897,26900,26902,26903,26906,26907,26908,26909,26910,26911,26912,26914,26915,26916,26918,26920,26925,26926,26927,26928,28894,28895,28897,28903,28905,28906,28907,28910,28912,28914,28915,28916,28917,28918,28924,28925,28927,28933,28936,28938,28944,28947,28948,28950,28953,28955,28957,31089,31096,31112,31085,31110,31106,31091,31099,31109,31104,31113,31108,31094,31101,31107,31111,31098,31105,31088,31103,31097,31102,31092,31149,31095,31090,31087,31100,31084,31048,31049,31050,31051,31052,31053,31054,31055,31056,31057,31058,31060,31061,31062,31063,31064,31065,31066,31067,31068,31070,31071,31072,31076,31077,31078,31079,31080,31081,31082,31083,31252,32178,32179,32259,32801,32807,32808,32809,32810,32867,32869,32870,32866,32868,32871,32874,32872,32873,34069,34590,34960,34961,34955,34959,36523,36524,36525,36526,37818,37855,38068,38175,38503,38504,39451,39452,39455,39458,39463,39462,39466,39467,39470,39471,39705,39712,39706,39714,39711,39713,39710,39717,39715,39716,39718,39719,39722,39725,39724,39721,39720,39723,39729,39731,39730,39732,39728,39727,39736,39733,39735,39734,39737,39738,39741,39739,39742,39740,39963,39961,40514,41418,41414,41415,41420,41429,42558,42588,42589,42590,42593,42591,42592,43493,44794,46126,46124,46127,46122,46125,46123,46403,46404,46405,46597,46601,46775,46776,46777,46778,46779,46803,47053,47054,47055,47056,47280,48789,51311,53831,53832,53834,53835,53843,53844,53845,54017,53934,53940,53941,53943,53852,53853,53854,53855,53857,53856,53859,53860,53861,53862,53863,53864,53865,53866,53867,53868,53869,53870,53871,53872,53873,53874,53875,53876,53877,53878,53879,53880,53881,53882,53883,53884,53885,53886,53887,53888,53889,53890,53891,53892,53893,53894,53916,53917,53918,53919,53920,53921,53922,53923,53924,53925,53926,53927,53928,53929,53930,53931,53932,53933,53830,53945,53946,53947,53948,53949,53950,53951,53952,53953,53954,53955,53956,53957,53958,53959,53960,53961,53962,53963,53964,53965,53966,53967,53968,53969,53970,53971,53972,53973,53974,53975,53976,53977,53978,53979,53980,53981,53982,53983,53984,53985,53986,53987,53988,53989,53990,53991,53992,53993,53994,54019,54023,54010,54011,54012,54013,54014,53995,53996,53997,53998,54000,54001,54002,54003,54004,54005,54006,54007,54008,54009,55384,55386,55387,55388,55390,55392,55393,55394,55395,55407,55396,55397,55398,55399,55400,55401,55402,55403,55404,55405,55389,55534,56049,56052,56053,56054,56055,56056,56074,56076,56077,56079,56081,56083,56084,56085,56087,56088,56089,56086,56193,56194,56195,56196,56197,56199,56201,56202,56203,56205,56206,56208,56496,56497,56498,56499,56500,56501,56530,56531,58141,58142,58143,58144,58145,58146,58147,58148,58149,58150,58507,58492,58954,59759 },

	[3273] = 
--	{ 3273,3274,7924,10846,27028,45542,10846 },
	{ 3273,3274,3275,3276,3277,3278,7928,7929,7924,7934,7935,10846,10840,10841,18629,18630,23787,27028,27032,27033,45545,45546,45542,10846,3276,7934,3277,3278,7928,7929,10840,10841,18629 },

	[45357] = 
--	{ 45357,45358,45359,45360,45361,45363 },
	{ 45357,45358,45359,45360,45361,45363,45382,48114,48116,48247,50612,50614,50616,50617,50618,50619,50620,50598,50599,50600,50601,50602,50603,50604,50605,50606,50607,50608,50609,50610,50611,51005,52175,52738,52739,48248,52840,52843,53462,57207,57208,57209,57210,57211,57212,57213,57214,57215,57216,57217,57218,57219,57220,57221,57222,57223,57224,57225,57226,57227,57228,57229,57230,57231,57703,57704,57706,57707,57708,57709,57710,57711,57712,57713,57714,57715,57716,56955,56963,56961,48121,56945,56951,56948,56953,56956,56959,56957,56952,56943,56946,56947,56960,56950,56944,56954,56958,56949,57004,57009,56995,56997,57005,57007,56994,57000,57001,57002,57008,57003,56996,56999,57012,57013,57006,57011,56998,57010,56976,56978,56968,56971,56973,56974,56981,56982,56979,56985,56984,56972,56989,56986,56980,56983,57719,56975,56977,56987,56988,57022,57027,57029,57030,57031,57032,57020,57023,57024,57025,57026,57033,57036,57034,57035,57021,57028,57019,57194,57196,57184,57186,57188,57197,57200,57201,57183,57185,57187,57192,57193,57198,57191,57195,57202,57189,57181,57199,57190,57114,57119,57120,57121,57123,57125,57129,57131,57132,57133,57122,57113,57116,57124,57128,57115,57126,57127,57112,57117,57130,57239,57246,57238,57240,57245,57249,57241,57242,57244,57251,57236,57252,57233,57232,57247,57248,57235,57243,57250,57234,57237,57259,57266,57265,57262,57269,57271,57277,57270,57274,57272,57275,57257,57264,57273,57258,57267,57260,57268,57261,57263,57276,58484,58485,58486,58487,58488,58489,58490,58491,58472,58473,58476,58478,58480,58481,58482,58483,58565,59480,59487,59491,59502,59503,59504,61117,61119,61120,61118,61177,61288,58296,58289,58299,58301,58298,58300,58303,58306,58310,58308,58314,58313,58312,58318,58317,58326,58323,58337,58342,58344,58346,58343,58286,58288,58305,58311,58315,58320,58325,58332,59326,58336,58345,58307,58324,58328,58331,58340,59315,58287,58302,58316,58321,58333,58329,58330,58338,58339,58319,58297,58327,58347,58322,58341,57162,57158,59475,59478,57163,57157,57167,59484,59486,57161,57165,59499,59387,60336,59489,59490,59488,57151,57154,59493,59494,57156,59495,59496,59338,57168,59339,59340,57172,60337,59497,59498,59500,59501,57159,57170,57152,57169,57160,57166,59559,57155,59561,57153,57164,59560,57014,61677 },

	[4036] = 
--	{ 4036,4037,4038,12656,20222,20219,30350,51306 },
	{ 4036,4037,4038,3918,3919,3920,3922,3923,3924,3925,3977,3973,3926,3928,3929,3930,3931,3932,3933,3934,3936,3937,3938,3978,3939,3940,3941,3942,3944,3945,3946,3947,3949,3950,3952,3953,3954,3955,3956,3957,3958,3959,3960,3961,3962,3963,3979,3965,3966,3967,3968,3969,3971,3972,6458,7430,8243,8334,8339,8895,9269,9271,9273,12584,12585,12586,12587,12590,12589,12591,12594,12595,12596,12597,12599,12603,12607,12614,12615,12616,12617,12618,12619,12620,12621,12622,12624,12656,12715,12716,12717,12718,12760,12720,12722,12755,12754,12759,12758,12895,12897,12899,12900,12902,12903,12904,12905,12906,12907,12908,13240,15255,15633,15628,19567,19788,19790,19792,19791,19793,19794,19796,19814,19795,19815,19799,19800,19819,19831,19830,19825,19833,20222,20219,21940,22704,22793,22795,22797,4073,12749,19804,23066,23068,23067,23069,23070,23071,23077,23078,23079,23080,23081,23082,23096,23129,13166,13258,23489,23486,23507,24356,24357,26011,26416,26417,26418,26420,26421,26422,26423,26424,26425,26426,26427,26428,26442,26443,28327,30350,30310,30311,30312,30313,30314,30315,30316,30317,30318,30325,30329,30332,30334,30337,30341,30342,30343,30344,30346,30347,30348,30349,30303,30304,30305,30306,30307,30308,30309,30547,30548,30549,30551,30552,30556,30558,30560,30561,30563,30565,30566,30568,30569,30570,30573,30574,30575,32814,36954,36955,39895,39971,39973,40274,41307,41311,41312,41314,41315,41316,41317,41318,41319,41320,41321,43676,44155,44157,44391,46111,46115,46109,46107,46112,46114,46108,46110,46116,46113,46106,46697,49383,51306,53281,54353,55252,56273,56349,54736,54998,54999,55002,54793,55016,56460,56459,56461,56464,56463,56465,56471,56466,56467,56468,56470,56472,56514,56473,56474,56475,56462,56476,56477,56469,56478,56479,56480,56481,56574,56483,56484,56486,56487,60867,60866,60874,61471,61481,61482,61483 },

	[2656] = 
--	{ 2656 },
	{ 2580,2575,2576,2656,2658,2659,3308,3307,3304,3564,3569,2657,8388,10098,10097,10248,14891,16153,29354,29356,29358,29359,29360,29361,29686,32606,35750,35751,46353,49252,49258,50310,55208,55211,22967,53120,53121,53122,53123,53124,53040 },

	[2018] = 
--	{ 2018,3100,3538,9785,9788,9787,17039,17040,17041,29844,51300 },
	{ 2018,2660,2663,3100,3115,3117,3116,3292,3293,3294,3295,3296,3297,3319,3320,3321,3323,3324,3325,3326,3328,3330,3331,3333,3334,3336,3337,3491,3492,3493,3494,3495,3496,3497,3498,3500,3501,3502,3503,3504,3505,3506,3507,3508,3511,3513,3515,3538,6518,6517,2671,2673,7224,7223,7221,7222,7408,7817,7818,8366,8367,8368,8768,8880,9785,9788,9787,9811,9813,9814,9818,9820,9916,9918,9921,9920,9926,9928,9931,9933,9935,9937,9939,9942,9945,9950,9952,9954,9957,9959,9961,9964,9966,9968,9970,9972,9974,9979,9980,9983,9985,9986,9987,9993,9995,9997,10001,10003,10005,10007,10009,10011,10013,10015,11643,12260,12259,11454,14379,14380,15296,15293,15292,15294,15295,15972,15973,16641,16640,16639,16642,16643,16644,16645,16646,16647,16648,16649,16650,16651,16652,16653,16654,16667,16656,16660,16655,16657,16658,16659,16662,16663,16664,16665,16724,16725,16726,16730,16728,16729,16731,16732,16741,16742,16744,16745,16746,16960,16965,16967,16969,16970,16971,16973,16978,16980,16983,16984,16985,16986,16987,16988,16990,16991,16992,16993,16994,16995,17039,17040,17041,16661,19666,19667,19668,19669,20201,20874,20872,20876,20873,20897,20890,21161,21913,22757,23628,23629,23632,23633,23636,23637,23638,23639,23650,23652,23653,24136,24138,24137,24139,24140,24141,24399,24914,24912,24913,27585,27588,27586,27589,27590,27587,27830,27829,27832,28244,28242,28243,28461,28462,28463,29545,29547,29548,29549,29550,29551,29552,29553,29556,29557,29558,29565,29566,29568,29569,29571,29603,29605,29606,29608,29611,29610,29613,29614,29615,29616,29617,29619,29620,29621,29628,29629,29630,29642,29643,29645,29648,29649,29654,29656,29657,29658,29622,29662,29663,29664,29668,29669,29671,29672,29692,29693,29694,29695,29696,29697,29698,29699,29700,29728,29729,29844,32284,32285,32655,32656,32657,34533,34545,34538,34529,34535,34541,34547,34543,34542,34534,34548,34546,34540,34544,34537,34530,34607,34608,34979,34981,34982,34983,36122,36125,36128,36126,36124,36137,36129,36136,36135,36133,36134,36130,36131,36256,36257,36258,36259,36260,36261,36262,36263,36389,36390,36391,36392,38473,38475,38476,38477,38478,38479,40034,40036,40035,40033,41132,41133,41135,41134,42662,42688,43549,43846,46141,46144,46142,46140,51300,52568,52569,52570,52567,52571,52572,54550,54551,54552,54553,54554,54555,54556,54557,54917,54918,54941,54944,54945,54946,54947,54948,54949,54978,54979,54980,54981,55013,55017,55014,55015,55055,55056,55057,55058,55174,55177,55179,55181,55182,55183,55184,55185,55186,55187,55200,55201,55203,55204,55202,55206,55298,55300,55301,55302,55303,55304,55305,55306,55307,55308,55309,55311,55310,55312,55371,55372,55373,55374,55375,55376,55369,55370,55377,55628,55641,55656,55730,55732,55834,55835,55839,56234,56280,56357,56400,56549,56550,56551,56552,56553,56554,56555,56556,59405,59406,59436,59438,59440,59441,59442,61008,61009,61010,2737,2738,2662,2739,2661,2664,2665,2740,2666,2741,2667,2668,2742,2670,2672,2674,2675 },

	[2259] =
--	{ 2259,3101,3464,11611,28596,28677,28675,28672,51304 },
	{ 2259,2330,2329,3101,3171,3172,3173,3174,3176,3177,2333,3188,3170,3230,3447,3448,3449,3450,3451,3452,3453,3454,3464,4508,4942,6624,6618,6617,7179,7181,7183,7257,7258,7255,7259,7256,7836,7837,7841,7845,8240,11449,11450,11451,11448,11452,11453,11456,11457,11458,11459,11460,11461,11464,11465,11466,11467,11468,11472,11473,11476,11477,11478,11479,11480,11611,12609,15833,17187,17551,17552,17553,17554,17555,17556,17557,17559,17561,17566,17560,17563,17562,17564,17565,17570,17571,17572,17573,17574,17575,17576,17577,17578,17579,17580,17632,17634,17635,17636,17637,17638,3175,21923,22732,22808,24266,24365,24366,24367,24368,25146,26277,28596,28543,28544,28545,28546,28549,28550,28552,28551,28553,28554,28555,28556,28557,28558,28562,28563,28564,28565,28566,28567,28568,28569,28570,28575,28571,28572,28577,28573,28576,28578,28579,28585,28583,28584,28582,28580,28581,28586,28590,28587,28588,28589,28591,28677,28675,28672,29688,32765,32766,33732,33738,33740,33733,33741,38070,38960,38962,38961,39636,39637,39638,39639,41458,41500,41501,41502,41503,42736,45061,47050,47046,47049,47048,51304,53812,53836,53837,53838,53840,53842,53847,53895,53898,53900,53905,53904,53903,53902,53901,53899,53848,53841,53839,53777,53776,53781,53782,53775,53774,53773,53771,53779,53780,53783,53784,53942,53936,53937,53938,53939,54020,54213,54218,54220,54221,54222,53042,56519,57425,57427,58868,58871,60403,60396,60405,60354,60355,60356,60357,60365,60366,60367,60350,60893,2331,2332,2334,2335,2336,2337 },
}



SkilletData = {}				-- skillet data scanner
SkilletLink = {}


local TradeSkillIDsByName = {}		-- filled in with ids and names for reverse matching (since the same name has multiple id's based on level)

local DifficultyText = {
	x = "unknown",
	o = "optimal",
	m = "medium",
	e = "easy",
	t = "trivial",
}
local DifficultyChar = {
	unknown = "x",
	optimal = "o",
	medium = "m",
	easy = "e",
	trivial = "t",
}


local skill_style_type = {
	["unknown"]			= { r = 1.00, g = 0.00, b = 0.00, level = 5, alttext="???", cstring = "|cffff0000"},
	["optimal"]	        = { r = 1.00, g = 0.50, b = 0.25, level = 4, alttext="+++", cstring = "|cffff8040"},
	["medium"]          = { r = 1.00, g = 1.00, b = 0.00, level = 3, alttext="++",  cstring = "|cffffff00"},
	["easy"]            = { r = 0.25, g = 0.75, b = 0.25, level = 2, alttext="+",   cstring = "|cff40c000"},
	["trivial"]	        = { r = 0.50, g = 0.50, b = 0.50, level = 1, alttext="",    cstring = "|cff808080"},
	["header"]          = { r = 1.00, g = 0.82, b = 0,    level = 0, alttext="",    cstring = "|cffffc800"},
}



-- adds an recipe source for an itemID (recipeID produces itemID)
function Skillet:ItemDataAddRecipeSource(itemID,recipeID)
	if not itemID or not recipeID then return end
	
	if not self.data.itemRecipeSource then
		self.data.itemRecipeSource = {}
	end
	
	if not self.data.itemRecipeSource[itemID] then		
		self.data.itemRecipeSource[itemID] = {}
	end
	
	self.data.itemRecipeSource[itemID][recipeID] = true
end


-- adds a recipe usage for an itemID (recipeID uses itemID as a reagent)
function Skillet:ItemDataAddUsedInRecipe(itemID,recipeID)
	if not itemID or not recipeID then return end
	
	if not self.data.itemRecipeUsedIn then
		self.data.itemRecipeUsedIn = {}
	end
	
	if not self.data.itemRecipeUsedIn[itemID] then
		self.data.itemRecipeUsedIn[itemID] = {}
	end
	
	self.data.itemRecipeUsedIn[itemID][recipeID] = true
end


-- goes thru the stored recipe list and collects reagent and item information as well as skill lookups
function Skillet:CollectRecipeInformation()
	
--[[
	for recipeID in pairs(self.db.account.recipeDB) do
		local recipe = self:GetRecipe(recipeID)
		
		if recipe.itemID ~= 0 then
			self:ItemDataAddRecipeSource(recipe.itemID, recipeID)
		end
		
		local reagentData = recipe.reagentData

		if reagentData then
			for r=1,#reagentData do
				self:ItemDataAddUsedInRecipe(reagentData[r].id, recipeID)
			end
		end
	end
]]
	for recipeID, recipeString in pairs(self.db.account.recipeDB) do

		local tradeID, itemString, reagentString, toolString = string.split(" ",recipeString)
		local itemID, numMade = 0, 1
		local slot = nil
		
		if itemString ~= "0" then
			local a, b = string.split(":",itemString)
			
			if a ~= "0" then 
				itemID, numMade = a,b
			else
				itemID = 0
				numMade = 1
				slot = tonumber(b)
			end
			
			if not numMade then
				numMade = 1
			end
		end
		
		itemID = tonumber(itemID)
		
		if itemID ~= 0 then
			self:ItemDataAddRecipeSource(itemID, recipeID)
		end
		

		local reagentList = { string.split(":",reagentString) }
		local numReagents = #reagentList / 2
		
		for i=1,numReagents do
			local reagentID = tonumber(reagentList[1 + (i-1)*2])
			
			self:ItemDataAddUsedInRecipe(reagentID, recipeID)
		end
	end
	
	
	for player,tradeList in pairs(self.db.server.skillDB) do
		self.data.skillIndexLookup[player] = {}
		
		for trade,skillList in pairs(tradeList) do
			for i=1,#skillList do
--				local skillData = self:GetSkill(player, trade, i)
				local skillString = self.db.server.skillDB[player][trade][i]

				local data = { string.split(" ",skillString) }
				
				if data[1] ~= "header" then
					local recipeID = string.sub(data[1],2)
				
					self.data.skillIndexLookup[player][recipeID] = i
				end
			end
		end
	end
end



-- Checks to see if the current trade is one that we support.

function Skillet:IsSupportedTradeskill(tradeID)
	if not tradeID or tradeID == 5419 then
		return false				-- beast training
	end
	
	if IsShiftKeyDown() then
		return false
	end
	
	return true
end

local missingVendorItems = {
	[30817] = true,				-- simple flour
	[4539] = true,				-- Goldenbark Apple
	[17035] = true,				-- Stranglethorn seed
	[17034] = true, 			-- Maple seed
}
		
		
-- queries periodic table for vendor info for a particual itemID
function Skillet:VendorSellsReagent(itemID)
	if PT then
		if missingVendorItems[itemID] then
			return true
		end
		
		if PT:ItemInSet(itemID,"Tradeskill.Mat.BySource.Vendor") then
			return true
		end
	end
end

-- resets the blizzard tradeskill search filters just to make sure no other addon has monkeyed with them
function SkilletData:ResetTradeSkillFilter()
	SetTradeSkillItemNameFilter("")	 			
	SetTradeSkillItemLevelFilter(0,0)
end


function SkilletLink:ResetTradeSkillFilter()
	SetTradeSkillItemNameFilter("")	 			
	SetTradeSkillItemLevelFilter(0,0)
end



function Skillet:IsRecipe(id)
	if not id then return end
	return true

--[[	
	return recipeName
	
	local m,i = string.split("/",id)
	
	local recipeModule = self.recipeDataModules[m]
	
	if recipeModule and tonumber(i) then
		return true
	end
]]
end



	
function SkilletData:GetRecipeName(id)
	if not id then return "unknown" end

	local name = GetSpellInfo(id)
--DebugSpam("name "..(id or "nil").." "..(name or "nil"))

	if name then return name, id end
	
	return tostring(id), id
end
	


function Skillet:GetRecipeName(id)
	if not id then return "unknown" end
	
	local name = GetSpellInfo(id)
--DebugSpam("name "..(id or "nil").." "..(name or "nil"))

	if name then return name, id end
	
	
	id = tonumber(id)
	
	local name = "unknown"
	
	for n,m in pairs(self.recipeDataModules) do
		if recipeName == "unknown" then
			recipeName = m.GetRecipeName(m, id)
		end
	end
	
	return recipeName
end




function Skillet:GetRecipe(id)
--DEFAULT_CHAT_FRAME:AddMessage("getrecipe "..(id or "nil"))
	if not id or id == 0 then return self.unknownRecipe end
	
	local recipe = self.unknownRecipe
	
	id = tonumber(id)
	
	for n,m in pairs(self.recipeDataModules) do
		if recipe == self.unknownRecipe then
			recipe = m.GetRecipe(m,id)
		end
	end

	return recipe, id
end


-- reconstruct a recipe from a recipeString and cache it into our system for this session
function SkilletData:GetRecipe(id)
	if not id or id == 0 then return self.unknownRecipe end
--DEFAULT_CHAT_FRAME:AddMessage("skilletData "..(id or "nil"))

	if (not Skillet.data.recipeList[id]) and Skillet.db.account.recipeDB[id] then	
		local recipeString = Skillet.db.account.recipeDB[id]
		
		local tradeID, itemString, reagentString, toolString = string.split(" ",recipeString)
		local itemID, numMade = 0, 1
		local slot = nil
		
		if itemString ~= "0" then
			local a, b = string.split(":",itemString)
			
			if a ~= "0" then 
				itemID, numMade = a,b
			else
				itemID = 0
				numMade = 1
				slot = tonumber(b)
			end
			
			if not numMade then
				numMade = 1
			end
		end
		
		Skillet.data.recipeList[id] = {}
		
		Skillet.data.recipeList[id].spellID = tonumber(id)
		
		Skillet.data.recipeList[id].name = GetSpellInfo(tonumber(id))
		Skillet.data.recipeList[id].tradeID = tonumber(tradeID)
		Skillet.data.recipeList[id].itemID = tonumber(itemID)
		Skillet.data.recipeList[id].numMade = tonumber(numMade)
		
		Skillet.data.recipeList[id].slot = slot
		
		Skillet.data.recipeList[id].reagentData = {}

		local reagentList = { string.split(":",reagentString) }
		local numReagents = #reagentList / 2
		
		for i=1,numReagents do
			Skillet.data.recipeList[id].reagentData[i] = {}
			
			Skillet.data.recipeList[id].reagentData[i].id = tonumber(reagentList[1 + (i-1)*2])
			Skillet.data.recipeList[id].reagentData[i].numNeeded = tonumber(reagentList[2 + (i-1)*2])
		end
		
		if toolString ~= "-" then
			Skillet.data.recipeList[id].tools = {}
		
			local toolList = { string.split(":",toolString) }

			for i=1,#toolList do
				Skillet.data.recipeList[id].tools[i] = string.gsub(toolList[i],"_"," ")
			end
		end
	end
	
	return Skillet.data.recipeList[id] or Skillet.unknownRecipe
end




function Skillet:GetNumSkills(player, trade)

	
	local skillModule = self.dataGatheringModules[player]
	
	if skillModule then
		return skillModule.GetNumSkills(skillModule, player, trade)
	end
	
	return 0
end




function Skillet:GetSkillRanks(player, trade)	
	local skillModule = self.dataGatheringModules[player]
	
	if skillModule then
		return skillModule.GetSkillRanks(skillModule, player, trade)
	end
end


function SkilletLink:GetSkillRanks(player, trade)
	if Skillet.db.server.linkDB[player] and Skillet.db.server.linkDB[player][trade] then
		local _,_,tradeID, rank, maxRank = string.find(Skillet.db.server.linkDB[player][trade], "trade:(%d+):(%d+):(%d+)")
		return rank .. " " .. maxRank
	end
	
	if (IsTradeSkillLinked()) then
		local _, linkedPlayer = IsTradeSkillLinked()
		
		if linkedPlayer == player then
			local skill, rank, max = GetTradeSkillLine()
		
			if GetSpellInfo(trade) == skill then
				return rank.." "..max
			end
		end
	end
end


function SkilletLink:GetNumSkills(player, trade)
	if (IsTradeSkillLinked()) then
		local _, linkedPlayer = IsTradeSkillLinked()
		
--		if linkedPlayer == player then
			local skill, rank, max = GetTradeSkillLine()
			
			if GetSpellInfo(trade) == skill then
				return GetNumTradeSkills()
			end
--		end
	end
	
	return 0
end


function SkilletData:GetSkillRanks(player, trade)
	return Skillet.db.server.skillRanks[player][trade]
end


function SkilletData:GetNumSkills(player, trade)
	return #Skillet.db.server.skillDB[player][trade]
end



function Skillet:GetSkill(player,trade,index)
--DEFAULT_CHAT_FRAME:AddMessage("getskill "..(player or "noplayer").." "..(trade or "notrade").." "..(index or "noindex"))
	
	local skillModule = self.dataGatheringModules[player]
	
	if skillModule then
		return skillModule.GetSkill(skillModule, player,trade,index)
	else
		return self.unknownRecipe
	end
end




function SkilletLink:GetSkill(player,trade,index)
	if player and trade and index then
		if not Skillet.data.skillList[player] or not Skillet.data.skillList[player][trade] then
			self:RescanTrade()
		end
--DEFAULT_CHAT_FRAME:AddMessage("getskillLink "..(player or "noplayer").." "..(trade or "notrade").." "..(index or "noindex"))

		return Skillet.data.skillList[player][trade][index]
	end
end



function SkilletLink:GetRecipe(id)
	if not id or id == 0 then return self.unknownRecipe end


	if (not Skillet.data.recipeList[id]) then	
		self:RescanTrade()
--DEFAULT_CHAT_FRAME:AddMessage("can't find recipe "..id);
	end
	
	return Skillet.data.recipeList[id] or Skillet.unknownRecipe
end





function SkilletLink:ScanTrade()
DebugSpam("ScanTrade")
	if self.scanInProgress == true then
DebugSpam("SCAN BUSY!")
		return
	end
	
	self.scanInProgress = true
	
	local tradeID
	
	local API = {}
	
	local profession, rank, maxRank = GetTradeSkillLine()
DebugSpam("GetTradeSkill: "..(profession or "nil"))

	
	-- get the tradeID from the profession name (data collected earlier).
	tradeID = TradeSkillIDsByName[profession] or 2656				-- "mining" doesn't exist as a spell, so instead use smelting (id 2656)

	if tradeID ~= Skillet.currentTrade then
DebugSpam("TRADE MISMATCH for player "..(Skillet.currentPlayer or "nil").."!  "..(tradeID or "nil").." vs "..(Skillet.currentTrade or "nil"));
	end

	
	local player = Skillet.currentPlayer
	
	if not self.recacheRecipe then
		self.recacheRecipe = {}
	end
	
	self:ResetTradeSkillFilter()						-- verify the search filter is blank (so we get all skills)

	
	local numSkills = GetNumTradeSkills()
	
DebugSpam("Scanning Trade "..(profession or "nil")..":"..(tradeID or "nil").." "..numSkills.." recipes")

	if not Skillet.data.skillIndexLookup[player] then
		Skillet.data.skillIndexLookup[player] = {}
	end
	
	local skillData = Skillet.data.skillList[player][tradeID]

	local lastHeader = nil
	local gotNil = false
	
	local currentGroup = nil
	
	local mainGroup = Skillet:RecipeGroupNew(player,tradeID,"Blizzard")
	
	mainGroup.locked = true
	mainGroup.autoGroup = true
	
	Skillet:RecipeGroupClearEntries(mainGroup)
	
	local groupList = {}
	
	local numHeaders = 0
			
			
	for i = 1, numSkills, 1 do
		repeat
--DebugSpam("scanning index "..i)
			local skillName, skillType, isExpanded, subSpell, extra
			
			
			skillName, skillType, _, isExpanded = GetTradeSkillInfo(i)
			
			
--DEFAULT_CHAT_FRAME:AddMessage("**** skill: "..(skillName or "nil").." "..i)

			gotNil = false
		
			
			if skillName then
				if skillType == "header" then
					numHeaders = numHeaders + 1
					
					if not isExpanded then
						ExpandTradeSkillSubClass(i)
					end

					local groupName
					
					if groupList[skillName] then
						groupList[skillName] = groupList[skillName]+1
						groupName = skillName.." "..groupList[skillName]
					else
						groupList[skillName] = 1
						groupName = skillName
					end
					
--					skillDB[i] = "header "..skillName
					skillData[i] = {}
					
					skillData[i].id = 0
					skillData[i].name = skillName
					
					currentGroup = Skillet:RecipeGroupNew(player, tradeID, "Blizzard", groupName)
					currentGroup.autoGroup = true
					
					Skillet:RecipeGroupAddSubGroup(mainGroup, currentGroup, i)
				else
					local recipeLink = GetTradeSkillRecipeLink(i)
					local recipeID = Skillet:GetItemIDFromLink(recipeLink)
					
					if not recipeID then
						gotNil = true
						break
					end
					
					if currentGroup then
						Skillet:RecipeGroupAddRecipe(currentGroup, recipeID, i)
					else
						Skillet:RecipeGroupAddRecipe(mainGroup, recipeID, i)
					end
					
					
					-- break recipes into lists by profession for ease of sorting
					skillData[i] = {}
				
	--					skillData[i].name = skillName
					skillData[i].id = recipeID					
					skillData[i].difficulty = skillType
					skillData[i].color = skill_style_type[skillType]
	--				skillData[i].category = lastHeader
					
					
--					local skillDBString = DifficultyChar[skillType]..recipeID
					
					
					local tools = { GetTradeSkillTools(i) }

					skillData[i].tools = {}
					
					local slot = 1
					for t=2,#tools,2 do
						skillData[i].tools[slot] = (tools[t] or 0)						
						slot = slot + 1
					end
					
					local cd = GetTradeSkillCooldown(i)
					
					if cd then
						skillData[i].cooldown = cd + time()		-- this is when your cooldown will be up
				
--						skillDBString = skillDBString.." cd=" .. cd + time()
					end

					local numTools = #tools+1
					
					if numTools > 1 then
						local toolString = ""
						local toolsAbsent = false
						local slot = 1
						
						for t=2,numTools,2 do
							if not tools[t] then
								toolsAbsent = true
								toolString = toolString..slot
							end
							
							slot = slot + 1
						end
						
						if toolsAbsent then										-- only point out missing tools
--							skillDBString = skillDBString.." t="..toolString
						end
					end
					
--					skillDB[i] = skillDBString
					
					Skillet.data.skillIndexLookup[player][recipeID] = i
					
--[[
					if recipeDB[recipeID] and not self.recacheRecipe[recipeID] then
						-- presumably the data is the same, so there's not much that needs to happen here.
						-- potentially, however, i could see an instance where a mod might feed tradeskill info and then "better" tradeskill info
						-- might be retrieved from the server which should over-ride the earlier tradeskill info
						-- (eg, tradeskillinfo sends skillet some data and then we learn that data was not quite up-to-date)

					else
]]
						Skillet.data.recipeList[recipeID] = {}
						
						local recipe = Skillet.data.recipeList[recipeID]
						local recipeString
						local toolString = "-"
						
						recipe.tradeID = tradeID
						recipe.spellID = recipeID
						
						recipe.name = skillName
						
						if #tools >= 1 then
							recipe.tools = { tools[1] }
							
							toolString = string.gsub(tools[1]," ", "_")
					
							for t=3,#tools,2 do
								table.insert(recipe.tools, tools[t])
								toolString = toolString..":"..string.gsub(tools[t]," ", "_")
							end
							
						end
						
						
						local itemLink = GetTradeSkillItemLink(i)
						
						if not itemLink then
							gotNil = true
							break
						end
						
						local itemString = "0"
						
						if GetItemInfo(itemLink) then
							local itemID = Skillet:GetItemIDFromLink(itemLink)
							
							local minMade,maxMade = GetTradeSkillNumMade(i)
						
							recipe.itemID = itemID
							recipe.numMade = (minMade + maxMade)/2
							
							if recipe.numMade > 1 then
								itemString = itemID..":"..recipe.numMade
							else
								itemString = itemID
							end
							
							Skillet:ItemDataAddRecipeSource(itemID,recipeID)					-- add a cross reference for the source of particular items
						else
							recipe.numMade = 1												
							recipe.itemID = 0												-- indicates an enchant
						end
						
						local reagentString = nil
						
						
						local reagentData = {}
		

						for j=1, GetTradeSkillNumReagents(i), 1 do
							local reagentName, _, numNeeded = GetTradeSkillReagentInfo(i,j)

							local reagentID = 0
							
							if reagentName then
								local reagentLink = GetTradeSkillReagentItemLink(i,j)

								reagentID = Skillet:GetItemIDFromLink(reagentLink)
							else
								gotNil = true
								break
							end
							
							reagentData[j] = {}
							
							reagentData[j].id = reagentID
							reagentData[j].numNeeded = numNeeded
							
--							if reagentString then
--								reagentString = reagentString..":"..reagentID..":"..numNeeded
--							else
--								reagentString = reagentID..":"..numNeeded
--							end
							
							Skillet:ItemDataAddUsedInRecipe(reagentID, recipeID)				-- add a cross reference for where a particular item is used
						end
						
						recipe.reagentData = reagentData
						
						if gotNil then
							self.recacheRecipe[recipeID] = true
						else
--							recipeString = tradeID.." "..itemString.." "..reagentString
							
--							if #tools then
--								recipeString = recipeString.." "..toolString
--							end
							
--							recipeDB[recipeID] = recipeString
						end
						
--					end
				end
			else
				gotNil = true
			end
		until true
		
		if gotNil and recipeID then
			self.recacheRecipe[recipeID] = true
		end
	end
	
	
--	Skillet:RecipeGroupConstructDBString(mainGroup)

DebugSpam("Scan Complete")
	
--	CloseTradeSkill()
		
	Skillet:InventoryScan()
	Skillet:CalculateCraftableCounts()
	Skillet:SortAndFilterRecipes()
DebugSpam("all sorted")
	self.scanInProgress = false
	
	collectgarbage("collect")
	
	if numHeaders == 0 then
		return false
	end
	
	return true
--	AceEvent:TriggerEvent("Skillet_Scan_Complete", profession)
end





-- reconstruct a skill from a skillString and cache it into our system for this session
function SkilletData:GetSkill(player,trade,index)
	if player and trade and index then
		if not Skillet.data.skillList[player] then
			Skillet.data.skillList[player] = {}
		end
		
		if not Skillet.data.skillList[player][trade] then
			Skillet.data.skillList[player][trade] = {}
		end
		
		if not Skillet.data.skillList[player][trade][index] then	
			local skillString = Skillet.db.server.skillDB[player][trade][index]
			
			if skillString then
				local skill = {}
				
				local data = { string.split(" ",skillString) }
				
				if data[1] == "header" then
					skill.id = 0
				else
					local difficulty = string.sub(data[1],1,1)
					local recipeID = string.sub(data[1],2)
					
					skill.id = tonumber(recipeID)
					skill.difficulty = DifficultyText[difficulty]
					skill.color = skill_style_type[DifficultyText[difficulty]]
					skill.tools = nil
					
					for i=2,#data do
						local subData = { string.split("=",data[i]) }
						
						if subData[1] == "cd" then
							skill.cooldown = tonumber(subData[2])

						elseif subData[1] == "t" then
							local recipe = Skillet:GetRecipe(recipeID)
						
							skill.tools = {}
							
							for j=1,string.len(subData[2]) do
								local missingTool = tonumber(string.sub(subData[2],j,j))
								skill.tools[missingTool] = true
							end
						end
					end
				end
				
				Skillet.data.skillList[player][trade][index] = skill
			end
		end
		
		return Skillet.data.skillList[player][trade][index]
	end
end


-- collects generic tradeskill data (id to name and name to id)
function Skillet:CollectTradeSkillData()
	for i=1,#TradeSkillList,1 do
		local id = TradeSkillList[i]
		local name, _, icon = GetSpellInfo(id)
		
		TradeSkillIDsByName[name] = id
	end

	self.tradeSkillIDsByName = TradeSkillIDsByName
	self.tradeSkillList = TradeSkillList
end


-- this routine collects the basic data (which tradeskills a player has)
-- clean = true means wipe the old data
function SkilletData:ScanPlayerTradeSkills(player, clean)	
	if player == (UnitName("player")) then			            -- only for active player

		if clean or not Skillet.db.server.skillRanks[player] then
			Skillet.db.server.skillRanks[player] = {}
		end
		
		local skillRanksData = Skillet.db.server.skillRanks[player]
		
		for i=1,#TradeSkillList,1 do

			local id = TradeSkillList[i]
			local name = GetSpellInfo(id)			            -- always returns data
			local _, rankName, icon = GetSpellInfo(name)		    -- only returns data if you have this spell in your spellbook
	
			
DebugSpam("collecting tradeskill data for "..name.." "..(rank or "nil"))

			if rankName then
				if not skillRanksData[id] then
					skillRanksData[id] = ""
				end
			else
				skillRanksData[id] = nil	
			end
		end
		
		if not Skillet.db.server.faction then
			Skillet.db.server.faction = {}
		end
	
		Skillet.db.server.faction[player] = UnitFactionGroup("player")

	end

	
	return Skillet.db.server.skillRanks[player]
end



-- this routine collects the basic data (which tradeskills a player has)
-- clean = true means wipe the old data
function SkilletLink:ScanPlayerTradeSkills(player, clean)	
	if Skillet.db.server.linkDB[player] then
		return true
	end
	
	local isLinked, playerLinked = IsTradeSkillLinked()
	
	if isLinked and player == playerLinked then
		return true
	end
end

-- [3273] = "|cffffd000|Htrade:3274:148:150:23F381A:zD<<t=|h[First Aid]|h|r",

local allDataInitialize = false
function Skillet:InitializeAllDataLinks(name)
	if allDataInitialized then return end
	
	allDataInitialized = true
	
	if not self.db.server.linkDB then
		self.db.server.linkDB = {}
	end
	
	self.db.server.linkDB[name] = {}
	
	local link = GetTradeSkillListLink()
	
	if not link then allDataInitialized = false return end
	
	
	local _,_,uid = string.find(link,"trade:%d+:%d+:%d+:([0-9a-fA-F]+)")
		
	for tradeID, recipeList in pairs(TradeSkillRecipeList) do
		local spellName = GetSpellInfo(tradeID)
		
		local encodingLength = floor((#recipeList+5) / 6)
		
		local encodedString = string.rep("{",encodingLength)
		
--DEFAULT_CHAT_FRAME:AddMessage("AllData Link "..tradeID.." "..(uid or "nil").." "..(spellName or "nil"))

		self.db.server.linkDB[name][tradeID] = "|cffffd00|Htrade:"..tradeID..":375:450:"..(uid or "23F381A")..":"..encodedString.."|h["..spellName.."]|h|r"
	end
	
	self:RegisterPlayerDataGathering(name,SkilletLink,"sk")
end


function Skillet:EnableDataGathering(addon)
	self:RegisterEvent("CHAT_MSG_SKILL")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("TRADE_SKILL_UPDATE")
	
	self.dataScanned = false
	
	self:CollectTradeSkillData()
	
	self:RegisterRecipeDatabase("sk",SkilletData)
	
	for player in pairs(self.db.server.linkDB) do
		self:RegisterPlayerDataGathering(player,SkilletLink,"sk")
	end
	
	
	self:RegisterPlayerDataGathering((UnitName("player")),SkilletData, "sk")		-- make sure to add the current player as well
	
	
	SkilletARL:Enable()
end
	


function Skillet:EnableQueue(addon)
	assert(tostring(addon),"Usage: EnableDataGathering('addon')")
--	self.queueaddons[addon] = true
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED",   "StopCastCheckUnit")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED",      "StopCastCheckUnit")
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "StopCastCheckUnit")
	self:RegisterEvent("UNIT_SPELLCAST_STOPPED",     "StopCastCheckUnit")
--	if not self.queue then
--		self.queue = {}
--	end
--	self.queueenabled = true
end


function Skillet:DisableQueue(addon)
--[[	if not addon then
		self.queue = nil
		self.queueaddons = {}
		self.queueenabled = false
		return
	end
	assert(tostring(addon),"Usage: DisableDataGathering(['addon'])")
	self.queueaddons[addon] = false
	if next(self.queueaddons) then
		return
	end
]]--
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:UnregisterEvent("UNIT_SPELLCAST_FAILED")
	self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:UnregisterEvent("UNIT_SPELLCAST_STOPPED")
--	self.queueenabled = false
--	self.queue = nil
end


-- takes a profession and a skill index and returns the recipe
function Skillet:GetRecipeDataByTradeIndex(tradeID, index)
	if not tradeID or not index then
		return self.unknownRecipe
	end
	
	local skill = self:GetSkill(self.currentPlayer, tradeID, index)

	if skill then 

		local recipeID = skill.id
		
		if recipeID then
	--		local recipeData = self.db.account.recipeData[recipeID] or selfUnknownRecipe
			local recipeData = self:GetRecipe(recipeID)
			
			return recipeData, recipeData.spellID
		end
	end
	
	return self.unknownRecipe, 0
end


function Skillet:StopCastCheckUnit(unit, spell, rank)
DebugSpam(event.." "..(unit or "nil"))
	if unit == "player" then
		self:StopCast(spell)
--		AceEvent:ScheduleEvent("Skillet_StopCast", self.StopCast, 0.1,self,event,spell)
	end
end


-- Internal
function Skillet:Skillet_AutoRescan()
local start = GetTime()
DebugSpam("AUTO RESCAN")
	if InCombatLockdown() then
		return
	end

	if AceEvent:IsEventScheduled("Skillet_AutoRescan") then
		AceEvent:CancelScheduledEvent("Skillet_AutoRescan")
	end

	if not self:RescanTrade() then
		AceEvent:ScheduleEvent("Skillet_AutoRescan", self.Skillet_AutoRescan, 0.5,self)
	end
	
	
	self:UpdateTradeSkillWindow()
DebugSpam("AUTO RESCAN COMPLETE")

local elapsed = GetTime() - start

--DEFAULT_CHAT_FRAME:AddMessage("Skillet Auto-Rescan: "..(math.floor(elapsed*100+.5)/100).." seconds")
end


function Skillet:TRADE_SKILL_UPDATE()
--DEFAULT_CHAT_FRAME:AddMessage("TRADE_SKILL_UPDATE "..(event or "nil").." "..(arg1 or "nil"))
	if AceEvent:IsEventScheduled("Skillet_AutoRescan") then
		AceEvent:CancelScheduledEvent("Skillet_AutoRescan")
	end
	
	AceEvent:ScheduleEvent("Skillet_AutoRescan", self.Skillet_AutoRescan, 0.5,self)
end


function Skillet:CHAT_MSG_SKILL()
--DEFAULT_CHAT_FRAME:AddMessage("CHAT_MSG_SKILL "..(event or "nil"))
--	self:Skillet_AutoRescan()									-- the problem here is that the message comes before the actuality, it seems
	if AceEvent:IsEventScheduled("Skillet_AutoRescan") then
		AceEvent:CancelScheduledEvent("Skillet_AutoRescan")
	end
	
	AceEvent:ScheduleEvent("Skillet_AutoRescan", self.Skillet_AutoRescan, 0.5,self)
end

function Skillet:CHAT_MSG_SYSTEM()
	local cutString = string.sub(1,(string.find(ERR_LEARN_RECIPE_S,"%s")))
--DebugSpam("CHAT_MSG_SYSTEM "..(arg1 or "nil").." vs "..cutString)
	if arg1 and string.find(arg1, cutString) then
--		self:Skillet_AutoRescan()								-- the problem here is that the message comes before the actuality, it seems
		if AceEvent:IsEventScheduled("Skillet_AutoRescan") then
			AceEvent:CancelScheduledEvent("Skillet_AutoRescan")
		end

		AceEvent:ScheduleEvent("Skillet_AutoRescan", self.Skillet_AutoRescan, 0.5,self)
	end
end



function Skillet:CalculateCraftableCounts(playerOverride)
DebugSpam("CalculateCraftableCounts")
	local player = playerOverride or self.currentPlayer
--	local skillDB = self.db.server.skillDB[player][self.currentTrade]
DebugSpam((player or "nil").." "..(self.currentTrade or "nil"))

DebugSpam("recalculating crafting counts")
	self.visited = {}
	

	for i=1,self:GetNumSkills(player, self.currentTrade) do
		local skill = self:GetSkill(player, self.currentTrade, i)
		
		if skill then			-- skip headers
			skill.numCraftable, skill.numCraftableVendor, skill.numCraftableBank, skill.numCraftableAlts = self:InventorySkillIterations(self.currentTrade, i, player)
		end
	end

DebugSpam("CalculateCraftableCounts Complete")
end





function Skillet:RescanTrade(force)
DebugSpam("RescanTrade")
	if not self.currentPlayer or not self.currentTrade then return end
	
	local dataModule = self.dataGatheringModules[self.currentPlayer]
	
	if dataModule and dataModule.RescanTrade then
		return dataModule.RescanTrade(dataModule, force)
	end	
end



-- Triggers a rescan of the currently selected tradeskill
function SkilletLink:RescanTrade(force)

	if not Skillet.currentPlayer or not Skillet.currentTrade then return end
	
	local player, tradeID = Skillet.currentPlayer, Skillet.currentTrade


	if not Skillet.data.skillList[player] then
		Skillet.data.skillList[player] = {}
	end
	
	if not Skillet.data.skillList[player][tradeID] then
		Skillet.data.skillList[player][tradeID]={}
	end
	
	if force then
DebugSpam("Forced Rescan")
--			self.db.server.skillRanks[self.currentPlayer]={}
		Skillet.data.skillList[player]={}
--			self.db.server.skillDB[self.currentPlayer]={}
--			self.db.server.groupDB = {}

		Skillet:InitializeDatabase(player, true)
	end

	
	Skillet:ScanQueuedReagents()

	Skillet.dataScanned = self:ScanTrade()

	DebugSpam("TRADESKILL HAS BEEN SCANNED")
	
	
	self:RecipeGroupGenerateAutoGroups()

	return Skillet.dataScanned
end




-- Triggers a rescan of the currently selected tradeskill
function SkilletData:RescanTrade(force)
--	if not SkilletFrame:IsVisible() then
--DebugSpam("Skillet frame not open")
--		return
--	end
	
	if not Skillet.currentPlayer or not Skillet.currentTrade then return end
	
	local player, tradeID = Skillet.currentPlayer, Skillet.currentTrade
	
--	self:InitializeDatabase(self.currentPlayer, false)
	
	
	if player == (UnitName("player")) then			-- only allow actual skill rescans of current player data
		if not Skillet.data.skillList[player] then
			Skillet.data.skillList[player] = {}
		end
		
		if not Skillet.data.skillList[player][tradeID] then
			Skillet.data.skillList[player][tradeID]={}
		end
		
					
		if not Skillet.db.server.skillDB[player] then
			Skillet.db.server.skillDB[player] = {}
		end
	
		if not Skillet.db.server.skillDB[player][tradeID] then
			Skillet.db.server.skillDB[player][tradeID] = {}
		end
		
		if force then
DebugSpam("Forced Rescan")
--			self.db.server.skillRanks[self.currentPlayer]={}
			Skillet.data.skillList[player]={}
--			self.db.server.skillDB[self.currentPlayer]={}
--			self.db.server.groupDB = {}

			Skillet:InitializeDatabase(player, true)
			
			local firstSkill
			
			for id,list in pairs(Skillet.db.server.skillRanks[player]) do
				if not firstSkill then
					firstSkill = id
				end
				
				Skillet.data.skillList[player][id] = {}
				Skillet.db.server.skillDB[player][id] = {}
			end
            
			Skillet.data.skillIndexLookup[player] = {}
				
			if not Skillet.db.server.skillRanks[player] then
				Skillet.currentTrade = firstSkill
			end
		end

		
		Skillet:ScanQueuedReagents()
	
		Skillet.dataScanned = self:ScanTrade()
	else				-- it's an alt, just do the inventory and craftability update stuff
		Skillet:ScanQueuedReagents()
		Skillet:InventoryScan()
		Skillet:CalculateCraftableCounts()
		
		Skillet.dataScanned = true
	end
	
	
	self:RecipeGroupGenerateAutoGroups()
	
	
	DebugSpam("TRADESKILL HAS BEEN SCANNED")
		
	return Skillet.dataScanned
end





function SkilletData:ScanTrade()
DebugSpam("ScanTrade")
	if self.scanInProgress == true then
DebugSpam("SCAN BUSY!")
		return
	end
	
	self.scanInProgress = true
	
	local tradeID
	
	local API = {}
	
	local profession, rank, maxRank = GetTradeSkillLine()
DebugSpam("GetTradeSkill: "..(profession or "nil"))


	API.GetNumSkills = GetNumTradeSkills
	API.ExpandLine = ExpandTradeSkillSubClass
	API.GetRecipeLink = GetTradeSkillRecipeLink
	API.GetTools = GetTradeSkillTools
	API.GetCooldown = GetTradeSkillCooldown
	API.GetItemLink = GetTradeSkillItemLink
	API.GetNumMade = GetTradeSkillNumMade
	API.GetNumReagents = GetTradeSkillNumReagents
	API.GetReagentInfo = GetTradeSkillReagentInfo
	API.GetReagentLink = GetTradeSkillReagentItemLink
	
	-- get the tradeID from the profession name (data collected earlier).
	tradeID = TradeSkillIDsByName[profession] or 2656				-- "mining" doesn't exist as a spell, so instead use smelting (id 2656)
	
--[[
	if profession ~= GetSpellName(tradeID) then
		DEFAULT_CHAT_FRAME:AddMessage("Skillet Error in Trade ID "..(profession or "nil").." ("..tradeID..")")
		self.scanInProgress = false
		return
	end
]]	
	
	if tradeID ~= Skillet.currentTrade then
DebugSpam("TRADE MISMATCH for player "..(Skillet.currentPlayer or "nil").."!  "..(tradeID or "nil").." vs "..(Skillet.currentTrade or "nil"));
	end

	
	local player = Skillet.currentPlayer
	
	if not self.recacheRecipe then
		self.recacheRecipe = {}
	end
	

	if not IsTradeSkillLinked() then
		Skillet.db.server.skillRanks[player][tradeID] = rank.." "..maxRank
	end
	
	
	self:ResetTradeSkillFilter()						-- verify the search filter is blank (so we get all skills)

	
	local numSkills = API.GetNumSkills()
	

DebugSpam("Scanning Trade "..(profession or "nil")..":"..(tradeID or "nil").." "..numSkills.." recipes")

	if not Skillet.data.skillIndexLookup[player] then
		Skillet.data.skillIndexLookup[player] = {}
	end
	
	local skillDB = Skillet.db.server.skillDB[player][tradeID]
	local skillData = Skillet.data.skillList[player][tradeID]
	local recipeDB = Skillet.db.account.recipeDB
	
	local lastHeader = nil
	local gotNil = false
	
	local currentGroup = nil
	
	local mainGroup = Skillet:RecipeGroupNew(player,tradeID,"Blizzard")
	
	mainGroup.locked = true
	mainGroup.autoGroup = true
	
	Skillet:RecipeGroupClearEntries(mainGroup)
	
	local groupList = {}
	
	
	if not Skillet.db.server.linkDB[player] then
		Skillet.db.server.linkDB[player] = {}
	end
	
	Skillet.db.server.linkDB[player][tradeID] = GetTradeSkillListLink()
	
	local numHeaders = 0
			
	for i = 1, numSkills, 1 do
		repeat
--DebugSpam("scanning index "..i)
			local skillName, skillType, isExpanded, subSpell, extra
			
			
			skillName, skillType, _, isExpanded = GetTradeSkillInfo(i)
			
			
--DebugSpam("**** skill: "..(skillName or "nil"))

			gotNil = false
		
			
			if skillName then
				if skillType == "header" then
					numHeaders = numHeaders + 1
					
					if not isExpanded then
						API.ExpandLine(i)
					end

					local groupName
					
					if groupList[skillName] then
						groupList[skillName] = groupList[skillName]+1
						groupName = skillName.." "..groupList[skillName]
					else
						groupList[skillName] = 1
						groupName = skillName
					end
					
					skillDB[i] = "header "..skillName
					skillData[i] = nil
					
					currentGroup = Skillet:RecipeGroupNew(player, tradeID, "Blizzard", groupName)
					currentGroup.autoGroup = true
					
					Skillet:RecipeGroupAddSubGroup(mainGroup, currentGroup, i)
				else
					local recipeLink = API.GetRecipeLink(i)
					local recipeID = Skillet:GetItemIDFromLink(recipeLink)
					
					if not recipeID then
						gotNil = true
						break
					end
					
					if currentGroup then
						Skillet:RecipeGroupAddRecipe(currentGroup, recipeID, i)
					else
						Skillet:RecipeGroupAddRecipe(mainGroup, recipeID, i)
					end
					
					
					-- break recipes into lists by profession for ease of sorting
					skillData[i] = {}
				
	--					skillData[i].name = skillName
					skillData[i].id = recipeID					
					skillData[i].difficulty = skillType
					skillData[i].color = skill_style_type[skillType]
	--				skillData[i].category = lastHeader
					
					
					local skillDBString = DifficultyChar[skillType]..recipeID
					
					
					local tools = { API.GetTools(i) }

					skillData[i].tools = {}
					
					local slot = 1
					for t=2,#tools,2 do
						skillData[i].tools[slot] = (tools[t] or 0)						
						slot = slot + 1
					end
					
					local cd = API.GetCooldown(i)
					
					if cd then
						skillData[i].cooldown = cd + time()		-- this is when your cooldown will be up
				
						skillDBString = skillDBString.." cd=" .. cd + time()
					end

					local numTools = #tools+1
					
					if numTools > 1 then
						local toolString = ""
						local toolsAbsent = false
						local slot = 1
						
						for t=2,numTools,2 do
							if not tools[t] then
								toolsAbsent = true
								toolString = toolString..slot
							end
							
							slot = slot + 1
						end
						
						if toolsAbsent then										-- only point out missing tools
							skillDBString = skillDBString.." t="..toolString
						end
					end
					
					skillDB[i] = skillDBString
					
					Skillet.data.skillIndexLookup[player][recipeID] = i
					
					if recipeDB[recipeID] and not self.recacheRecipe[recipeID] then
						-- presumably the data is the same, so there's not much that needs to happen here.
						-- potentially, however, i could see an instance where a mod might feed tradeskill info and then "better" tradeskill info
						-- might be retrieved from the server which should over-ride the earlier tradeskill info
						-- (eg, tradeskillinfo sends skillet some data and then we learn that data was not quite up-to-date)

					else
						Skillet.data.recipeList[recipeID] = {}
						
						local recipe = Skillet.data.recipeList[recipeID]
						local recipeString
						local toolString = "-"
						
						recipe.tradeID = tradeID
						recipe.spellID = recipeID
						
						recipe.name = skillName
						
						if #tools >= 1 then
							recipe.tools = { tools[1] }
							
							toolString = string.gsub(tools[1]," ", "_")
					
							for t=3,#tools,2 do
								table.insert(recipe.tools, tools[t])
								toolString = toolString..":"..string.gsub(tools[t]," ", "_")
							end
							
						end
						
						
						local itemLink = API.GetItemLink(i)
						
						if not itemLink then
							gotNil = true
							break
						end
						
						local itemString = "0"
						
						if GetItemInfo(itemLink) then
							local itemID = Skillet:GetItemIDFromLink(itemLink)
							
							local minMade,maxMade = API.GetNumMade(i)
						
							recipe.itemID = itemID
							recipe.numMade = (minMade + maxMade)/2
							
							if recipe.numMade > 1 then
								itemString = itemID..":"..recipe.numMade
							else
								itemString = itemID
							end
							
							Skillet:ItemDataAddRecipeSource(itemID,recipeID)					-- add a cross reference for the source of particular items
						else
							recipe.numMade = 1												
							recipe.itemID = 0												-- indicates an enchant
						end
						
						local reagentString = nil
						
						
						local reagentData = {}
		

						for j=1, API.GetNumReagents(i), 1 do
							local reagentName, _, numNeeded = API.GetReagentInfo(i,j)

							local reagentID = 0
							
							if reagentName then
								local reagentLink = API.GetReagentLink(i,j)

								reagentID = Skillet:GetItemIDFromLink(reagentLink)
							else
								gotNil = true
								break
							end
							
							reagentData[j] = {}
							
							reagentData[j].id = reagentID
							reagentData[j].numNeeded = numNeeded
							
							if reagentString then
								reagentString = reagentString..":"..reagentID..":"..numNeeded
							else
								reagentString = reagentID..":"..numNeeded
							end
							
							Skillet:ItemDataAddUsedInRecipe(reagentID, recipeID)				-- add a cross reference for where a particular item is used
						end
						
						recipe.reagentData = reagentData
						
						if gotNil then
							self.recacheRecipe[recipeID] = true
						else
							recipeString = tradeID.." "..itemString.." "..reagentString
							
							if #tools then
								recipeString = recipeString.." "..toolString
							end
							
							recipeDB[recipeID] = recipeString
						end
						
					end
				end
			else
				gotNil = true
			end
		until true
		
		if gotNil and recipeID then
			self.recacheRecipe[recipeID] = true
		end
	end
	
	
--	Skillet:RecipeGroupConstructDBString(mainGroup)

DebugSpam("Scan Complete")
	
--	CloseTradeSkill()
		
	Skillet:InventoryScan()
	Skillet:CalculateCraftableCounts()
	Skillet:SortAndFilterRecipes()
DebugSpam("all sorted")
	self.scanInProgress = false
	
	collectgarbage("collect")
	
	
	if numHeaders == 0 then
		return false
	end
	
	return true
--	AceEvent:TriggerEvent("Skillet_Scan_Complete", profession)
end


function SkilletData:EnchantingRecipeSlotAssign(recipeID, slot)
	local recipeString = Skillet.db.account.recipeDB[recipeID]
		
	local tradeID, itemString, reagentString, toolString = string.split(" ",recipeString)
	
	if itemString == "0" then
		itemString = "0:"..slot
		
		Skillet.db.account.recipeDB[recipeID] = tradeID.." 0:"..slot.." "..reagentString.." "..toolString
		
		Skillet:GetRecipe(recipeID)
--DEFAULT_CHAT_FRAME:AddMessage(Skillet.data.recipeList[recipeID].name or "noName")
			
		Skillet.data.recipeList[recipeID].slot = slot
	end
end



local invSlotLookup = {
	["HEADSLOT"] = "HeadSlot",
	["NECKSLOT"] = "NeckSlot",
	["SHOULDERSLOT"] = "ShoulderSlot",
	["CHESTSLOT"] = "ChestSlot",
	["WAISTSLOT"] = "WaistSlot",
	["LEGSSLOT"] = "LegsSlot",
	["FEETSLOT"] = "FeetSlot",
	["WRISTSLOT"] = "WristSlot",
	["HANDSSLOT"] = "HandsSlot",
	["FINGER0SLOT"] = "Finger0Slot",
	["TRINKET0SLOT"] = "Trinket0Slot",
	["BACKSLOT"] =	"BackSlot",
	["ENCHSLOT_WEAPON"] = "MainHandSlot",
	["ENCHSLOT_2HWEAPON"] = "MainHandSlot",
	["SHIELDSLOT"] = "SecondaryHandSlot",
}



function SkilletData:ScanEnchantingGroups(mainGroup)
	local groupList = {}
	
	if mainGroup then	
		local craftSlots = { GetCraftSlots() }
		
		Skillet:RecipeGroupClearEntries(mainGroup)
		
		for i=1,#craftSlots do
			local groupName
			local slotName = getglobal(craftSlots[i])
			
			local invSlot
			
			if groupList[slotName] then
				groupList[slotName] = groupList[slotName]+1
				groupName = slotName.." "..groupList[slotName]
			else
				groupList[slotName] = 1
				groupName = slotName
			end
					
			local currentGroup = Skillet:RecipeGroupNew(Skillet.currentPlayer, 7411, "Blizzard", groupName)			-- 7411 = enchanting
			
			SetCraftFilter(i+1)
			
			for s=1,GetNumCrafts() do
				local recipeLink = GetCraftRecipeLink(s)
				local recipeID = Skillet:GetItemIDFromLink(recipeLink)
				
				if craftSlots[i] ~= "NONEQUIPSLOT" then
					invSlot = GetInventorySlotInfo(invSlotLookup[craftSlots[i]])
					self:EnchantingRecipeSlotAssign(recipeID, invSlot)
				end
				
DebugSpam("adding "..(recipeLink or "nil").." to "..groupName)				
				Skillet:RecipeGroupAddRecipe(currentGroup, recipeID, Skillet.data.skillIndexLookup[Skillet.currentPlayer][recipeID])
				
--				local e = Skillet:RecipeGroupFindRecipe(mainGroup, "sk/"..recipeID)
--				
--				if e then
--					Skillet:RecipeGroupMoveEntry(e, currentGroup)
--				end
			end
			
			Skillet:RecipeGroupAddSubGroup(mainGroup, currentGroup, i)
		end
	end
	
	SetCraftFilter(1)
end



function Skillet:GenerateAltKnowledgeBase()
	local tradeID = Skillet.currentTrade
	local player = Skillet.currentPlayer
	
	local knownRecipes = {}
	local unknownRecipes = {}

	for label in pairs(Skillet.dataGatheringModules) do
		local rankString = Skillet:GetSkillRanks(label, tradeID)
	
		if label ~= "All Data" and rankString then

			Skillet:InitGroupList(player, tradeID, label, true)
			
			if label == Skillet.currentGroupLabel then
				
				local mainGroup =  Skillet:RecipeGroupNew(player, tradeID, label)
				
				
				if not mainGroup.initialized then
					local unknownCount = 0
					local knownCount = 0
					
					mainGroup.initialized = true
					
					local rank = string.split(" ", rankString)
					
					rank = tonumber(rank)
					
					-- first, accumulate all skill data
					for id, skill in pairs(Skillet.data.skillList[player][tradeID]) do
						local recipeID = skill.id

						if skill.id then
							spellID = skill.id
						
							unknownRecipes[spellID] = spellID
							unknownCount = unknownCount + 1
						end
					end


					-- then, move over all known recipes for this toon
					local numSkills = #Skillet.db.server.skillDB[label][tradeID]
					
					for i=1, numSkills do
						local skill = Skillet:GetSkill(label, tradeID, i)
						if skill and skill.id ~= 0 then
							local spellID = skill.id
							
							knownRecipes[spellID] = spellID
							unknownRecipes[spellID] = nil
							
							unknownCount = unknownCount - 1
							knownCount = knownCount + 1
						end
					end
					
				
					if knownCount > 0 then 
						local knownGroup = Skillet:RecipeGroupNew(player, tradeID, label, "Known Recipes")
						
						Skillet:RecipeGroupAddSubGroup(mainGroup, knownGroup, 1)
						
						for spellID,recipeID in pairs(knownRecipes) do
							local index = Skillet.data.skillIndexLookup[player][recipeID]
				
							local entry = Skillet:RecipeGroupAddRecipe(knownGroup, recipeID, index)
							
							entry.color = Skillet:GetTradeSkillLevelColor(spellID, rank)
							
							if entry.color then
								entry.difficulty = entry.color.level
							end
						end
					end
					
					
					if unknownCount > 0 then
						local unknownGroup = Skillet:RecipeGroupNew(player, tradeID, label, "Unknown Recipes")
						
						Skillet:RecipeGroupAddSubGroup(mainGroup, unknownGroup, 2)
						
						for spellID,recipeID in pairs(unknownRecipes) do
							local index = Skillet.data.skillIndexLookup[player][recipeID]
						
							local entry = Skillet:RecipeGroupAddRecipe(unknownGroup, recipeID, index)
							
							entry.color = Skillet:GetTradeSkillLevelColor(spellID, rank)
							
							if entry.color then
								entry.difficulty = entry.color.level
							end
						end
					end
				end
			end

		end
	end
	
	knownRecipes = nil
	unknownRecipes = nil
	
	DebugSpam("done making groups")
end


function SkilletData:RecipeGroupGenerateAutoGroups()
--	Skillet:RecipeGroupDeconstructDBStrings()
	Skillet:GenerateAltKnowledgeBase()
end



function SkilletLink:RecipeGroupGenerateAutoGroups()
--	Skillet:RecipeGroupDeconstructDBStrings()
	Skillet:GenerateAltKnowledgeBase()
end



-- arl hooks



SkilletARL = {}

			
local function initFilterButton(name, icon, parent, slot)
	local b = CreateFrame("CheckButton", name)
	b:SetWidth(20)
	b:SetHeight(20)
	
	b:SetParent(parent)
	
	
	b:SetNormalTexture(icon)
	b:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight", "ADD")
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	
	b:SetFrameLevel(this:GetFrameLevel()+5)
	
	b:SetScript("OnEnter", function(button) SkilletARL:RecipeFilterButton_OnEnter(button) end)
	b:SetScript("OnLeave", function(button) SkilletARL:RecipeFilterButton_OnLeave(button) end)
	b:SetScript("OnClick", function(button) SkilletARL:RecipeFilterButton_OnClick(button) end)
	b:SetScript("OnShow", function(button) SkilletARL:RecipeFilterButton_OnShow(button) end)
	
	b.slot = slot
	
	return b
end



function SkilletARL:RecipeFilterButtons_Hide()
	local b = self.arlRecipeSourceButton
	
	if b then
		b.trainerButton:Hide()
		b.vendorButton:Hide()
		b.questButton:Hide()
		b.dropButton:Hide()
		b.mobButton:Hide()
		b.unknownButton:Hide()
	end
end


function SkilletARL:RecipeFilterButtons_Show()
	local b = self.arlRecipeSourceButton
	
	if b then
		b.trainerButton:Show()
		b.vendorButton:Show()
		b.questButton:Show()
		b.dropButton:Show()
		b.mobButton:Show()
		b.unknownButton:Show()
	end
end


function SkilletARL:RecipeFilterButton_OnClick(button)
	local slot = button.slot or ""
	local option = "recipeSourceFilter-"..slot
	
	Skillet:ToggleTradeSkillOption(option)

	self:RecipeFilterButton_OnEnter(button)
	self:RecipeFilterButton_OnShow(button)
	Skillet:SortAndFilterRecipes()
	Skillet:UpdateTradeSkillWindow()
end


function SkilletARL:RecipeFilterButton_OnEnter(button)
	local slot = button.slot or ""
	local option = "recipeSourceFilter-"..slot
	local value = Skillet:GetTradeSkillOption(option)
	
	GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT")
	
	if value then
		GameTooltip:SetText(slot.." on")
	else
		GameTooltip:SetText(slot.." off")
	end
--	GameTooltip:AddLine(player,1,1,1)
		
	GameTooltip:Show()
end


function SkilletARL:RecipeFilterButton_OnLeave(button)
	GameTooltip:Hide()
end

function SkilletARL:RecipeFilterButton_OnShow(button)
	local slot = button.slot or ""
	local option = "recipeSourceFilter-"..slot
	
	local value = Skillet:GetTradeSkillOption(option)
	
	if value then
		button:SetChecked(1)
	else
		button:SetChecked(0)
	end
end


function SkilletARL:RecipeFilterToggleButton_OnShow(button)
	local filter = Skillet:GetTradeSkillOption("recipeSourceFilter")

	if filter then
		this:SetChecked(1)
	else
		this:SetChecked(0)
	end
end


function SkilletARL:RecipeFilterToggleButton_OnEnter(button)
	GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT")

	GameTooltip:SetText("Filter recipes by source", nil, nil, nil, nil, 1)
	GameTooltip:AddLine("Left-Click to toggle", .7, .7, .7)
	GameTooltip:AddLine("Right-Click for filtering options", .7, .7, .7)
	GameTooltip:Show()
		
	GameTooltip:Show()
end


function SkilletARL:RecipeFilterToggleButton_OnLeave(button)
	GameTooltip:Hide()
end



function SkilletARL:RecipeFilterToggleButton_OnClick(button, mouse)
	if mouse=="LeftButton" then
		SkilletARL:RecipeFilterButtons_Hide()	
		if button:GetChecked() then
			PlaySound("igMainMenuOptionCheckBoxOn");
		end
		local before = Skillet:GetTradeSkillOption("recipeSourceFilter")
		Skillet:SetTradeSkillOption("recipeSourceFilter", not before)
		Skillet:SortAndFilterRecipes()
		Skillet:UpdateTradeSkillWindow()
	else
		if ARLRecipeSourceTrainerButton:IsVisible() then
			SkilletARL:RecipeFilterButtons_Hide()
		else
			SkilletARL:RecipeFilterButtons_Show()
		end
		
		if Skillet:GetTradeSkillOption("recipeSourceFilter") then
			button:SetChecked(1)
		else
			button:SetChecked(0)
		end
	end
end



function SkilletARL:RecipeSourceButtonInit()
	if not self.arlRecipeSourceButton then

		local b = CreateFrame("CheckButton", "ARLRecipeSourceFilterButton")
		
		b:SetWidth(20)
		b:SetHeight(20)

		b:SetNormalTexture("Interface\\Icons\\INV_Scroll_03")
		b:SetPushedTexture("Interface\\Icons\\INV_Scroll_03")
		b:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight", "ADD")
		b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
		b:SetDisabledTexture("Interface\\Icons\\INV_Scroll_03")
		b:RegisterForClicks("LeftButtonUp", "RightButtonDown")
		
		self.arlRecipeSourceButton = b
		
		b:SetScript("OnClick", function(button) SkilletARL:RecipeFilterToggleButton_OnClick(button, arg1) end)
		b:SetScript("OnEnter", function(button) SkilletARL:RecipeFilterToggleButton_OnEnter(button) end)
		b:SetScript("OnLeave", function(button) SkilletARL:RecipeFilterToggleButton_OnLeave(button) end)
		b:SetScript("OnShow", function(button) SkilletARL:RecipeFilterToggleButton_OnShow(button) end)
		
		b.trainerButton = initFilterButton("ARLRecipeSourceTrainerButton", "Interface\\Addons\\Skillet\\Icons\\vendor_icon.tga", b, "trainer")
		b.trainerButton:SetPoint("TOP", b:GetName(), "BOTTOM", -50,0)
	
		
		b.vendorButton = initFilterButton("ARLRecipeSourceVendorButton", "Interface\\Addons\\Skillet\\Icons\\vendor_icon.tga", b, "vendor")
		b.vendorButton:SetPoint("LEFT", "ARLRecipeSourceTrainerButton", "RIGHT", 0,0)
	
		
		b.questButton = initFilterButton("ARLRecipeSourceQuestButton", "Interface\\Icons\\INV_Misc_Map_01", b, "quest")
		b.questButton:SetPoint("LEFT", "ARLRecipeSourceVendorButton", "RIGHT", 0,0)

		
		b.dropButton = initFilterButton("ARLRecipeSourceDropButton", "Interface\\Icons\\Ability_DualWield", b, "drop")
		b.dropButton:SetPoint("LEFT", "ARLRecipeSourceQuestButton", "RIGHT", 0,0)
		
		
		b.mobButton = initFilterButton("ARLRecipeSourceMobButton", "Interface\\Icons\\INV_Scroll_06", b, "mob")
		b.mobButton:SetPoint("LEFT", "ARLRecipeSourceDropButton", "RIGHT", 0,0)
		
		b.unknownButton = initFilterButton("ARLRecipeSourceUnknownButton", "Interface\\Icons\\INV_Misc_QuestionMark", b, "unknown")
		b.unknownButton:SetPoint("LEFT", "ARLRecipeSourceMobButton", "RIGHT", 0,0)
	end
	
	local _,_,icon = GetSpellInfo(Skillet.currentTrade)
	
	if icon then
		self.arlRecipeSourceButton.trainerButton:SetNormalTexture(icon)
	end
	
	self:RecipeFilterButtons_Hide()
	
	return self.arlRecipeSourceButton
end


	
local ARLProfessionInitialized = {}

-- return true if the skill needs to be filtered out
function SkilletARL:RecipeFilterOperator(skillIndex)
	if Skillet:GetTradeSkillOption("recipeSourceFilter") then	
		local skill = Skillet:GetSkill(Skillet.currentPlayer, Skillet.currentTrade, skillIndex)
		
		local _, recipeList, mobList, trainerList = AckisRecipeList:InitRecipeData()
		
		recipeData = AckisRecipeList:GetRecipeData(skill.id)
		
		if recipeData == nil and not ARLProfessionInitialized[Skillet.currentTrade] then
			local profession = GetSpellInfo(Skillet.currentTrade)
			
			AckisRecipeList:AddRecipeData(profession)
			ARLProfessionInitialized[Skillet.currentTrade] = true
			 
			recipeData = AckisRecipeList:GetRecipeData(skill.id)
		end
		
		
		if recipeData then
			recipeSource = recipeData["Acquire"]
			
			for i,data in pairs(recipeSource) do
				if data["Type"] == 1 and Skillet:GetTradeSkillOption("recipeSourceFilter-trainer") then
					return false
				end
				
				if data["Type"] == 2 and Skillet:GetTradeSkillOption("recipeSourceFilter-vendor") then
					return false
				end
				
				if data["Type"] == 3 and Skillet:GetTradeSkillOption("recipeSourceFilter-mob") then
					return false
				end
				
				if data["Type"] == 4 and Skillet:GetTradeSkillOption("recipeSourceFilter-quest") then
					return false
				end
				
				if data["Type"] == 5 and Skillet:GetTradeSkillOption("recipeSourceFilter-drop") then
					return false
				end
			end
		else
			if Skillet:GetTradeSkillOption("recipeSourceFilter-unknown") then
				return false
			end
		end
		
		return true
	end
	
	return false
end


function SkilletARL:Enable()
	
	if AckisRecipeList then
		Skillet:RegisterRecipeFilter("arlRecipeSource", self, self.RecipeSourceButtonInit, self.RecipeFilterOperator)
				
		Skillet.defaultOptions["recipeSourceFilter"] = false
		Skillet.defaultOptions["recipeSourceFilter-drop"] = true
		Skillet.defaultOptions["recipeSourceFilter-vendor"] = true
		Skillet.defaultOptions["recipeSourceFilter-trainer"] = true
		Skillet.defaultOptions["recipeSourceFilter-quest"] = true
		Skillet.defaultOptions["recipeSourceFilter-mob"] = true
		Skillet.defaultOptions["recipeSourceFilter-unknown"] = true
	end
end




-- common skills hooks

-- [id] = itemCreated[:count] itemReagents:count[:...] [level]
local commonSkillsRecipes = {
	[13361] = "10939 10938:3",			-- greater magic essence
	[13362] = "10938:3 10939:1",			-- lesser magic essence
}


SkilletCommonSkills = {}





