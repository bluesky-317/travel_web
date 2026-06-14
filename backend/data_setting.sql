-- ============================================================
-- Travel Web attraction seed data
-- Source: backend/attraction_dt.json
-- Target schema: User, Category, City, Attraction, Itinerary, ItineraryItem
-- This script is idempotent: lookup tables use INSERT IGNORE, attractions use upsert.
-- It resets attraction-related tables before importing, so AUTO_INCREMENT ids start from 1.
-- ============================================================

USE TravelDB;
SET NAMES utf8mb4;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE ItineraryItem;
TRUNCATE TABLE Attraction;
TRUNCATE TABLE Category;
TRUNCATE TABLE City;
SET FOREIGN_KEY_CHECKS = 1;

START TRANSACTION;

-- 1) Seed category lookup values.
INSERT IGNORE INTO Category (name) VALUES
    ('戶外體驗'),
    ('林業歷史與人文'),
    ('生態觀察與動植物'),
    ('自然景觀');

-- 2) Seed city lookup values.
INSERT IGNORE INTO City (name) VALUES
    ('南投縣'),
    ('台中市'),
    ('台北市'),
    ('台南市'),
    ('台東縣'),
    ('嘉義市'),
    ('嘉義縣'),
    ('基隆市'),
    ('宜蘭縣'),
    ('屏東縣'),
    ('彰化縣'),
    ('新北市'),
    ('新竹市'),
    ('新竹縣'),
    ('桃園市'),
    ('澎湖縣'),
    ('花蓮縣'),
    ('苗栗縣'),
    ('連江縣'),
    ('金門縣'),
    ('雲林縣'),
    ('高雄市');

-- 3) Seed attractions.
INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000001', '太平山國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '自然景觀' LIMIT 1), (SELECT city_id FROM City WHERE name = '宜蘭縣' LIMIT 1), '宜蘭縣大同鄉太平巷58之1號', 24.5574676798311, 121.49949962026885, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0100001/01_%E5%A4%AA%E5%B9%B3%E5%B1%B1%E5%9C%8B%E5%AE%B6%E6%A3%AE%E6%9E%97%E9%81%8A%E6%A8%82%E5%8D%80.jpg', '蹦蹦車、溫泉、高山湖泊、巨木森林與國寶山毛櫸，鋪成了太平山國家森林遊樂區超過百年歷史的綿長軌跡。  太平山舊稱「眠腦」，是泰雅族語「鬱鬱蒼蒼」之意。1914年，日本人先做了資源調查，1915年決議開發。《台灣日日新報》在1936年7月28日報導：「太平山之名乃由現在事務所轉移前，當時主任技師中里氏，將蕃語直譯者。且佐久間總督五年討伐告終，天下歸於太平之意」。所以，「天下太平」才是太平山地名真正的由來，命名者正是踏查先鋒中里正。  海拔2000公尺的太平山，是僅次於阿里山的林業傳奇，1915年日本人開始這裡的伐木事業，後來由國民政府接手，成為台灣最大的林場，最後在1983年轉型為遊樂區，留下見晴鐵道、蹦蹦車等珍貴的遺跡。  人們可以漫步在鎮安宮後的原始林間，讓思緒翱翔在過往巨木滿山的年代。沿著時常遇見台灣獼猴、帝雉等動物的翠峰景觀道路行駛，終點是台灣面積最大高山湖泊，海拔1840公尺的翠峰湖，對岸是國寶台灣山毛櫸的家，秋天可以沿著4公里的步道欣賞滿山金黃耀眼。  收費站不遠處的鳩之澤溫泉，是聞名遐邇的碳酸泉，也是這裏的一大特色。太平山國家森林遊樂區，絕對是喜歡大自然的您，拜訪宜蘭的第一選擇。', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0100001', 4.8, '(03)9770766', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000002', '滿月圓國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '新北市' LIMIT 1), '新北市三峽區有木里174-1號', 24.830781104172626, 121.44458529554898, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0200001/DSCN1261.jpg', '在三峽大豹溪的上游，一條叫做蚋子溪的支流上，座落著一個擁有瀑布、生態與楓紅的美麗小天地：滿月圓國家森林遊樂區。  距離三峽市區約40分鐘的滿月圓國家森林遊樂區，海拔在300至1700公尺之間，終年潮濕涼爽，孕育了豐富的蕨類生態，連對環境要求高的「團扇蕨」都可以找到。過去這裡曾有小規模的伐木，今日整齊的人造林見證了那段歲月。  這裡有豐富的鳥類、兩棲類及蝴蝶生態，像是少見的白喉笑鶇、赤腹山雀等，都是滿月圓重要的鳥明星喔！而每年12月左右，這裏的楓紅也美得動人，有「台灣最美低海拔楓紅」的美譽。  位於健行步道盡頭的滿月圓瀑布與處女瀑布，也是遊樂區的兩大美景，從滿月小橋上望去，只見一垂高十餘公尺之大石壁遮掩滿月圓瀑布上端，瀑布直沖而下，聲勢極為壯麗，處女瀑布則較為溫柔婉約，在陽光普照之日，光影在水瀑間折射變化，時常可見瀑布有著虹彩般的絢麗。', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0200001', 4.5, '(02)26720004', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000003', '內洞國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '自然景觀' LIMIT 1), (SELECT city_id FROM City WHERE name = '新北市' LIMIT 1), '新北市烏來區信賢里娃娃谷46號', 24.834425607300727, 121.5261399307585, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0200002/DSCN9298.jpg', '瀑聲隆隆，依山傍水的蕨類樂園，小巧精緻的內洞國家森林遊樂區，是南勢溪上游一個享受寧靜與綠意的好所在。  距新店約50分鐘，內洞可說是大台北地區交通最方便的國家森林遊樂區，海拔在230~1500公尺之間，被內洞溪流貫，潮濕而溫暖，是名副其實的蕨類樂園：光觀瀑步道的短短數百公尺，就能發現將近65種蕨類，包括稀有的垂枝馬尾杉與藤蕨等，都是大樹身上附生的嬌客。而這裡舊稱「娃娃谷」，相傳是因為蛙類眾多，在夜裡暢鳴的聲響迴盪山谷而得，步道旁的水溝就有機會見到青蛙的身影喔！  內洞瀑布是遊樂區的主角，在觀瀑步道終點，有著二層不同的風貌帶給遊人們多元享受，與暢快的負離子芬芳。炎炎夏日，不妨從悶熱的都市出走，到內洞國家森林遊樂區享受一個清涼的午後森林浴吧！', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0200002', 4.4, '(02)26617358', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000004', '東眼山國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '桃園市' LIMIT 1), '桃園市復興區霞雲里成福路600號', 24.831409228116122, 121.40794297727716, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0200003/IMG_1007.jpg', '距離大溪約1小時車程的東眼山國家森林遊樂區，過去曾是林業保育署(舊稱林務局)的伐木林班，留下了許多林業遺跡，如集材機、索道、台車等，隱身在知性步道旁。現今漫步在雲霧繚繞、整齊美麗的柳杉林間，拾級而上登頂海拔1,212公尺的東眼山一覽桃園到大台北的景緻。 東眼山林道旁座落著一塊造林紀念石，見證著台灣林業的過去。  東眼山豐富的生態，擁有約43種山鳥，以及為數眾多的哺乳動物，連中高海拔才有的白面鼯鼠都可以在這裡看見。春季賞櫻、夏季白天蟬和夜間各種青蛙比大聲，秋季東眼山林道染上濃濃的秋愁，最特別的是，有不少台灣野兔住在這裡，漫步林間時，別忘了注意您的腳邊唷！  而位於東眼山林道旁的化石區，擁有千萬年歷史的化石與地景，伴隨生痕化石、沉積地質等沿途漫步至東滿步道入口，十分愜意。有機會到大溪一遊，不妨也安排到東眼山國家森林遊樂區，來趟洗滌心神的森林之旅吧！', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0200003', 4.4, '(03)3821506', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000005', '觀霧國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '苗栗縣' LIMIT 1), '苗栗縣泰安鄉梅園村8鄰觀霧1-3號', 24.506065171717104, 121.11374599728552, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0200004/%E9%BB%83%E8%8A%B1%E9%B3%B3%E4%BB%99%E8%8A%B1.JPG', '在滿山的迷霧之中擁抱神木、春天欣賞全台最大霧社山櫻花的一樹雪白、登高一覽雪山山脈「聖稜線」的英姿、還可能巧遇國寶，這裡是觀霧國家森林遊樂區，在竹苗交界帶給人們最豐盛的霧林帶饗宴。  距離竹東2小時的觀霧，泰雅族語是「茂義利」，意思是「更高的山嶺」。這裡在1940年成為伐木林場，1980年才結束營業，留下了滿山整齊的人造林；而檜山巨木群步道上五株壯碩的紅檜巨木，則對著遊人們訴說昔日台灣森林的壯美。  觀霧的野生動物很有看頭，除了漫步林道的帝雉與山羌外，最特別的是全世界獨一無二的棣慕華鳳仙花，以及兩種台灣特有種國寶：寬尾鳳蝶與以「觀霧」為名的觀霧山椒魚。  園區聯外道路大鹿林道在此分叉，東線是往大霸尖山的路，而西線則可通往園區最高的榛山，帶領人們享受雪山山脈聖稜線所勾勒出的動人景緻。', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0200004', 4.6, '(03)5224163', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000006', '拉拉山國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '桃園市' LIMIT 1), '桃園市復興區華陵里13鄰巴崚205號', 24.710258290540935, 121.4327802792125, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0200005/0200005202302150.JPG', '拉拉山國家森林遊樂區(以下簡稱本區)位於桃園市復興區北橫上巴陵一帶，此地的泰雅族上巴陵部落，其名「Balung」正是「檜木」或「巨大的倒木」之意；而「拉拉」為泰雅族語「R’ra」音譯，有「美麗的」、「讚嘆的」、「眺望、守望」等意，一說係指本區為族人眺望獵物、防禦外敵之處所，亦有族人來到此地感到讚嘆、美好之意，皆足以顯現本區具有豐富的檜木與生態資源。  全世界檜木分布只有在北美、日本及臺灣的雲霧帶才會有，因此，拉拉山的檜木森林是很珍貴的。本區位於霧林帶，植群分類屬原始針、闊葉混合林，完整保育千百年自然環境造就的珍貴檜木巨木群；亦為臺灣藍鵲、黃腹琉璃、臺灣野山羊等野生動植物重要棲息環境，係北部中海拔山區極具代表性之森林生態系，具有豐富之自然及人文特色。', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0200005', 4.5, '(03)3882038', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000007', '武陵國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '台中市' LIMIT 1), '台中市和平區武陵路3號', 24.39719561381731, 121.30697874767868, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0300001/0300001202309200.jpg', '深藏在武陵農場深處，楓紅、松林、瀑布與臺灣櫻花鉤吻鮭譜出的森林之歌，是武陵國家森林遊樂區最令人印象深刻的意象。  這是台灣第三座國家森林遊樂區，距離台北約4個小時車程，海拔約1800公尺，但因高山寒氣沈降，十分寒冷。  園區內最具代表性的景點，莫過於桃山瀑布步道，沿途的二葉松林相十分幽靜，豐富的森林生態也是這裡的一大特色，台灣獼猴、帝雉、藍腹鷴、酒紅朱雀都是這裡的常客，步道盡頭水與霧雄壯澎湃的「桃山瀑布」令人歎為觀止，釋放滿滿的負離子療癒旅人的心靈。  在武陵吊橋上，還可以觀賞七家灣溪裡的國寶魚——臺灣櫻花鉤吻鮭呢！秋天的台灣紅榨槭、青楓紅葉，與春天的櫻花更是武陵國家森林遊樂區美麗的季節特色，是來到武陵一帶不可錯過的行程喔！  武陵國家森林遊樂區內台灣獼猴出沒頻繁，為減少人猴衝突，請遵守4不守則：  1.不餵食 ■餵食會降低獼猴對人的警戒心，使獼猴進而搶食人類食物，危及人身安全。 ■餵食會改變獼猴自然行為與生態，使獼猴與人類生活易產生衝突。 2.不接觸 ■不接觸獼猴，避免感染泡疹B病毒、狂犬病、腸胃道寄生蟲等人猴共通疾病。 ■獼猴跳到身上時，勿驚慌尖叫揮趕，鎮定離開原地，獼猴會自己離開。 3.不干擾挑釁 ■不瞪視、不逗弄、不挑釁、不讓孩童落單，減少人猴衝突。 4.食物不外露 ■零食、水果、飲品或任何具濃郁氣味的食品，應收入背包內不提拿在手上，也不要在獼猴面前作拉開背包的動作，減少獼猴上前拿取之衝突。', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0300001', 4.8, '(04)25901080', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000008', '八仙山國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '台中市' LIMIT 1), '台中市和平區東關路一段200之8號', 24.19713908236116, 121.00389817448416, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0300002/20140120-P1204043.jpg', '「八仙山為昔日三大林場之一，走過繁華喧囂的林業時光，於民國75年(1986)成立八仙山國家森林遊樂區，如今園區運用其資源地位，轉化林場設施語彙，復刻過去歷史記憶，並規劃具有景色多樣化的輕裝短途步道，園區內能尋訪美麗的十文溪、櫻花林、油桐林與竹林，更能循階登頂谷關七雄之首：海拔2366公尺的八仙山。 「八仙山」的命名是由日文轉譯而來，因為八仙山有「八千」日尺高，而取其諧音名為「八仙」。自1915年起至1963年間，八仙山長達48年的林業時光，留下了整齊劃一的人造林、索道頭以及神社和國小遺址等，訴說著林業的故事。而曾有過的森林鐵道，也在結束伐木後全數拆除，僅剩園區內的老照片供人回憶；除了史蹟尋訪外，園區內有非常豐富的鳥類生態，青背山雀、赤腹山雀、白耳畫眉及冠羽畫眉等都是常見的小明星，近年還觀察到國內首筆百步蛇野外護卵的紀錄，此外夜晚還有機會看到大赤鼯鼠、白面鼯鼠、鼬獾及食蟹獴等野生動物，臺灣獼猴則是日間最常在園區走跳的大明星。」', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0300002', 4.4, '(04)25951214', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000009', '大雪山國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '台中市' LIMIT 1), '台中市和平區雪山路18號', 24.244784793371075, 120.97504634020432, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0300003/01_BASE_02.jpg', '秋天的紅榨槭楓紅、夏夜的星空、向晚的雲海、穿梭林道間的山羌、帝雉與大台中唯一親民的紅檜巨木-雪山神木，是大雪山國家森林遊樂區最迷人的印象。  這裡曾是民國47年開採的大雪山林場，繁榮了東勢與豐原，如今這個距離東勢只消1小時的山城成為了森林遊樂區，繼續為中部的人們帶來屬於自然的恩惠。此地海拔超過2000公尺，氣候涼爽，目前僅存小神木步道與木馬道一帶保有原始的扁柏巨木林，是遊樂區最美的景色之一；而位於遊樂區最深處，高50公尺的雪山神木則曾是台灣第11大巨木呢！  野生動物更是大雪山最大的寶藏：山羌、長鬃山羊與白面鼯鼠熱鬧了黑夜，而白天則有帝雉、藍腹鷴與冠羽畫眉等一干山鳥雀躍跳耀；漫步林間享受森林浴的舒心之餘，也很容易跟這些小明星們不期而遇喔！', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0300003', 4.7, '(04)25877901', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000010', '合歡山國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '自然景觀' LIMIT 1), (SELECT city_id FROM City WHERE name = '花蓮縣' LIMIT 1), '花蓮縣秀林鄉關原65號', 24.142481448051424, 121.28428739735581, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0300004/P2170136.jpg', '說到雪與高山，「合歡山」肯定是台灣人的首選了，這也正是合歡山國家森林遊樂區最獨一無二的景緻。  合歡山國家森林遊樂區是台灣第一座國家森林遊樂區——早在1963年，因為特殊的景色與高山生態系而得此殊榮，在這裡你可以看見廣大的玉山箭竹草原、體驗整整低平地18度C的凜冽氣溫、輕鬆登臨園區內三座百岳名山：合歡主峰、合歡東峰與石門山，並住宿松雪樓享受夜裡華麗的壯闊星海。這裡也有許多高海拔限定的鳥兒：岩鷚、酒紅朱雀、火冠戴菊…等著你來拜訪喔！  雪景是合歡山的一大特色，冬季皚皚白雪是亞熱帶台灣最讓人心醉的夢幻景象，而每年五月，清麗動人的玉山杜鵑花海，將翠綠的山頭綴的紅白交錯，好像又降下瑞雪一般，令人驚艷，演繹著四季都精彩的合歡山國家森林遊樂區。', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0300004', 4.7, '(049)2802980', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000011', '奧萬大國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '南投縣' LIMIT 1), '南投縣仁愛鄉親愛村大安路153號', 23.954269695292318, 121.16951663830639, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0400001/01_%E5%A5%A7%E8%90%AC%E5%A4%A7%E5%90%8A%E6%A9%8B.%E8%83%BD%E9%AB%98%E5%8D%97%E5%B3%B0.%E6%A5%93%E9%A6%99.jpg', '滿山金黃的楓紅、壯觀的吊橋與野生動物環繞，奧萬大國家森林遊樂區是一座充滿魅力的森林。  奧萬大位於萬大水庫後方，海拔1100~2600公尺之間，這裡原為泰雅族及賽德克族部落，日本時代開始進行水力發電建設，在1994年才成為國家森林遊樂區。在泰雅族的語言中「奧」是深入、進入，奧萬大即是“深入萬大”之意，奧萬大國家森林遊樂區的楓紅名氣在國內首屈一指，但在園區中，隨著四季的更迭，不斷上演著大自然多彩、浪漫的景觀。  只是，賞楓名氣似乎掩蓋了奧萬大的四季之美，四季有韻是奧萬大的天生麗質，冬楓、春櫻、夏瀑及秋月，在這舒適的谷地裡悄悄更替，靜靜繽紛，只要您有閒情逸致，願意放下塵世瑣事，許自己一個滌淨身心的假期，那麼，任君挑選奧萬大四季之美景！  賞楓步道上大片的原生楓香林與遊客中心周遭的落羽松、青楓等，每逢秋季必將園區點綴得萬紫千紅，是奧萬大最熱鬧的季節，但春天櫻花的美其實也不遑多讓。而壯觀的「奧萬大吊橋」連接著美麗的松林區，長180公尺，高90公尺，可以眺望萬大南北溪交匯，也是拜訪奧萬大必遊的景點喔！', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0400001', 4.6, '(049)2974511', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000012', '阿里山國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '林業歷史與人文' LIMIT 1), (SELECT city_id FROM City WHERE name = '嘉義縣' LIMIT 1), '嘉義縣阿里山鄉中正村59號', 23.50881989610119, 120.80199592702066, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0500001/0500001202510230.jpg', '阿里山國家森林遊樂區擁有森林小火車、神木、雲海、日出與晚霞「五奇」景致，是台灣最具知名、也最受歡迎的森林遊樂區，是阿里山山脈上的一枚翡翠，閃著耀眼的光芒。  阿里山林業鐵路為著名的高山觀光森林鐵道，您可以至嘉義火車站搭乘森林小火車，一路輕晃享盡森林風情前往終點站阿里山(林業鐵路由阿里山林業鐵路及文化資產管理處轄管，林業鐵路本線及支線已全線通車)。又或者駕車沿台18線蜿蜒而上，不到兩個小時就能抵達88.2k處，海拔2,216公尺的阿里山國家森林遊樂區。  阿里山山脈為台灣五大山脈之一，惟阿里山並不是一座山，而是泛指這個山區；自古擁有豐沛的檜木資源，1912-1960年間為台灣最具規模的林場。歷經長期的採伐後，原始檜木林幾乎伐盡，現今存有第一期與第二期巨木群棧道近四十株的紅檜巨木，讓人緬懷過去神木林的壯闊神聖。著名的阿里山神木於1956年遭受雷擊後1997年又有半邊因雨倒伏，林業及自然保育署為了順應自然生態、尊重生命及維護遊客安全，於1998年6月將阿里山神木原地放倒供遊客欣賞。於2006年經票選由「阿里山香林神木」當選第二代神木，高45公尺，樹圍12.3公尺，是到訪阿里山的必遊之處。  在阿里山國家森林遊樂區內有豐富的生態，其中最特殊的植物，莫過於稀有的蓧蕨、相馬氏石杉、阿里山十大功勞與臺灣一葉蘭了；動物則有台灣獼猴、帝雉、藪鳥、阿里山鴝、阿里山山椒魚等小明星助陣，熱鬧非凡。  除了神木，阿里山還有非常多具可看性的景點：森林小火車、空靈飄渺的姊妹潭、壯闊動人的雲海、美麗的祝山日出、受鎮宮、百年慈雲寺、林業史蹟、春天盛開的各類櫻花與杜鵑…阿里山國家森林遊樂區是一個足以代表臺灣霧林帶的國際級觀光景點，歡迎著來自全世界的旅人們，前來認識台灣山林豐富而美麗的面貌。', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0500001', 4.9, '(05)2679715', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000013', '藤枝國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '高雄市' LIMIT 1), '高雄市桃源區寶山里寶山巷150號', 23.067601811046355, 120.75460022502105, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0600001/0600001202304203.JPG', '有「森濤」美名的藤枝國家森林遊樂區，是南部地區享受森林浴、夏日避暑、玩賞生態最好的去處。 距離高雄市、屏東市、臺南市約莫2小時車程的藤枝，過去是布農族人的生活區域，日治時期在此設立京都大學實驗林，因此有台灣少見的日本扁柏以及大面積的柳杉造林地。而著名的六龜警備線通過此地，留有不少遺跡。  園區海拔在1500~1804公尺間，涼爽宜人。此地的「霧林帶」中，生長著牛樟、木荷、杏葉石櫟等大樹，更有以此為名的「藤枝秋海棠」與眾多稀有蕨類，十分珍貴；並且孕育了豐富的生態，能找到許多難得一見的昆蟲，如路易士角葫蘆鍬形蟲、大綠目天蠶蛾、台灣爺蟬等。這裡也是全台灣最容易看見黃山雀的地點之一，十分特別，是個十分適合健行賞鳥的好地方呢！', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0600001', 4.3, '(07)6893118', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000014', '墾丁國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '屏東縣' LIMIT 1), '屏東縣恆春鎮墾丁里公園路201號', 21.958724278213854, 120.81203853828217, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0600002/160054.jpg', '墾丁國家森林遊樂區原本是許多石珊瑚蟲、石灰藻類、有孔蟲及貝殼聚生的海洋花園，因為50萬年前地球的板塊運動，成為了一種特殊的森林生態系─高位珊瑚礁林，兼具豐富生態、季風雨林、石灰岩地形，為遊客提供了不一樣的墾丁遊憩選擇。  這裡距離墾丁大街只有10分鐘，是台灣第二座國家森林遊樂區，擁有發達的高位珊瑚礁森林與季風雨林：緊嵌礁岩上的大茄苳、板根發達的銀葉樹與氣根無數的白榕等。1906年日本人在此成立「恆春熱帶植物園」，至今已有百年歷史。  園區常見成群台灣獼猴與赤腹松鼠，幸運的遊客能一睹梅花鹿與食蟹檬的芳蹤，最有看頭的莫過於秋冬來訪的候鳥了，如10月的灰面鵟鷹，甚至稀有的黃鸝，都能一見芳蹤，而森林底層則住著台灣特有的黃灰澤蟹與班卡拉蝸牛等小嬌客。  墾丁國家森林遊樂區另一大特色就是石灰岩地形，在銀龍洞、石筍寶穴等溶洞裡，可以看見鐘乳石、石筍等地質寶藏。這個奇幻森林，絕對能讓喜愛探險的你大飽眼福！', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0600002', 4.3, '(08)8861211', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_000016', '知本國家森林遊樂區', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '台東縣' LIMIT 1), '台東縣卑南鄉溫泉村龍泉路290號', 22.68733032919047, 120.99126980724618, 'https://recreation.forest.gov.tw/Files/Forest/RA/photo/album/0700001/03_BASE_03.jpg', '知本國家森林遊樂區海拔高度110~650公尺，全年氣候溫暖濕潤。園區內動植物種類繁多，主要景觀有百年大白榕、百年酸藤、花見知本百草園等。遊樂區更是生態旅遊、森林療癒、親子活動、夜間觀察的最佳去處，近年陸續優化了園區步道系統、木育體驗設施，並陸續推出知本香氛系列製品，讓美好的森林記憶延伸至生活中。     開一扇窗，啟一段森林的美好！113年更啟動了賣店空間改造工程，引進視覺美學新設了一扇長達6公尺大跨距觀景窗，讓旅人在賣店就能「眺望整座森林」，讓清新的山景與瀑布一覽無遺。並打造東部第一間「山林製造」品牌概念店—「山林製造」X「虎比公寓知本館」，以自然保育及永續發展為主軸，創新森林育樂場域賣店經營思維，連結民眾與森林生態系創造多元服務價值。 賣店室內空間也選用了國產材進行細節裝修，並精選了臺東山村在地餐食、特色工藝、山林讀物、臺東植萃氣味地景與戶外生活等多樣商品，讓人走入空間就有如走入知本森林，就能感受臺灣森林的美好。', '依園區公告', '依公告收費', 'https://recreation.forest.gov.tw/Forest/RA?typ_id=0700001', 4.2, '(089)510961', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_030023', '奧萬大自然教育中心', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '南投縣' LIMIT 1), '南投縣仁愛鄉親愛村大安路153號', 23.953644889261522, 121.17902668726221, 'https://recreation.forest.gov.tw/Files/Education/NC/Album/AWD/01_%E6%B4%BB%E5%8B%95%E7%85%A7%E7%89%873.JPG', '嬉遊在繽紛多彩的松楓林，透過身歷其境的活動，感受自然的脈動，體驗森林多功能價值，了解山林與文明的連結。  奧萬大自然教育中心位於奧萬大國家森林遊樂區內，全區屬狹谷地形，為多條溪流匯集處，四面環山，「春櫻、夏瀑、秋月、冬楓」四季皆美，且是野生物良好的棲息環境。奧萬大吊橋可遠眺溪谷之美及能高南峰，是園區最佳賞景攬勝之處。', '預約或依公告', '活動另計', 'https://recreation.forest.gov.tw/Education/NC?typ_id=AWD', 4.1, '(049)2974499', '2026-05-06 12:20:10')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_030027', '東眼山自然教育中心', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '桃園市' LIMIT 1), '桃園市復興區霞雲里成福路600號', 24.82501763742406, 121.41755757108434, 'https://recreation.forest.gov.tw/Files/Education/NC/Album/DYS/01_DYS.JPG', '在雪山山脈尾稜的柳杉林裡，在真實的環境學習中，創造「人與人」、「人與環境」、「人與社會」之對話。  東眼山自然教育中心位於東眼山國家森林遊樂區內，屬石門水庫集水區範圍，為雪山山脈西稜之一部份，山形恰似人倒臥的側臉，清晨日出由側臉眼窩的位置升起，因而得名。森林組成兼具整齊優美的人工林及豐富多樣的天然林，還有三千萬年前蝦蟹留下的生痕化石，及其他海相沈積等地質景觀。', '預約或依公告', '活動另計', 'https://recreation.forest.gov.tw/Education/NC?typ_id=DYS', 4.1, '(03)3821533', '2026-05-06 12:20:10')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_100034', '阿里山林業村暨檜意森活村', (SELECT category_id FROM Category WHERE name = '林業歷史與人文' LIMIT 1), (SELECT city_id FROM City WHERE name = '新竹市' LIMIT 1), '新竹市東區共和路370號', 23.48623555134025, 120.4539392888454, 'https://recreation.forest.gov.tw/Files/Forestry/CP/photo/album/0900021/01_BASE_01.jpg', '阿里山林業始於1899年，日治時期阿里山林場檜木資源而闢建阿里山林業鐵路，起點就在嘉義市北門，木材買賣集散為嘉義市帶來前所未有的繁榮，當時更因此列為臺灣四大都市之一。1906年5月，日本民間企業藤田組成立嘉義施工所，為興建阿里山森林鐵路開啟序幕，惟因工程艱鉅且經費膨脹，於1908年2月告終。至1910年起臺灣總督府接手，阿里山鐵路繼續興築，1914年阿里山林業鐵路本線全長71.9公里，就此完成。  當時的營林機關建築群的規模日漸擴大，包括營林辦公廳舍、營林俱樂部、製材所、東南亞第一座火力發電建築物逐一完工。砍伐的林木，經由阿里山林業鐵路運到嘉義「杉池」，為當時東南亞規模最大儲木池。嘉義因林業繁榮，當時的嘉義被稱為「木材都市」，現今的林森路即為當時的「木材街」，周邊林務機關群區域則被稱為「檜町」。當年林務機關也因木材產業興盛，生產、生活機能十分完備，林業村已儼然成形。  民國53年阿里山林產事業告一段落，嘉義市之製材業也逐漸沒落。近百年歷史的林業資產，見證了嘉義市林業發展興衰，隨著歲月的流轉，更散發出濃濃的風味，成為珍貴的林業文化資產，卻逐漸有頹傾之虞，必須予以活化更新，再現風華。營林俱樂部、嘉義市共和路與北門街林管處國有宿眷舍及原嘉義製材所(竹材工藝品加工廠)，見證了阿里山林業開採的相關歷史，分別於87年及94年登錄為嘉義市歷史建築。', '依店家公告', '免費', 'https://recreation.forest.gov.tw/Forestry/CP?typ_id=0900021', 4.4, '(05)2779843', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_345040000G_110036', '烏來台車', (SELECT category_id FROM Category WHERE name = '林業歷史與人文' LIMIT 1), (SELECT city_id FROM City WHERE name = '新北市' LIMIT 1), '新北市烏來區溫泉街86巷2號', 24.861007409574857, 121.55051609407586, 'https://recreation.forest.gov.tw/Files/Forestry/FR/photo/album/0200041/06_BASE_03.jpg', '烏來台車初期僅為輸運木材，因烏來瀑布觀光發展遊客需求，於52年正式開辦客運，以人力推送遊客，為因應日漸成長之遊客量，乃於63年實施機動化，以柴油引擎推動台車，再於76年排除萬難在瀑布站開鑿隧道取代原來的轉盤迴轉，沿用迄今。  營運路線由烏來至瀑布全長1.5公里，於每日9至17時往返行駛，並配合夏季旺季時節調整營運時間，隨到隨開以服務旅客。', '依班次公告', '車票另計', 'https://recreation.forest.gov.tw/Forestry/FR?typ_id=0200041', 4.5, '(02)26617826', '2026-05-06 12:20:09')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_371020000A_000376', '邱良功古厝', (SELECT category_id FROM Category WHERE name = '林業歷史與人文' LIMIT 1), (SELECT city_id FROM City WHERE name = '金門縣' LIMIT 1), '金門縣金城鎮浯江街27號', 24.43263, 118.31778, 'https://kinmen.travel/image/8258/640x480', '這棟建築乃為邱良功祖厝，位於金城鎮浯江街中段，屋中尚存有方形銅鏡一面，另有雕龍聖旨石二塊，高六十一公分、寬八十五公分，所刻聖旨二字每字十二公分見方，據傳係良功顯貴封爵，皇帝聞其家屋簡陋，賜建爵府，故贈予聖旨石二塊，預備置於府第大門前坊，建築物為一落四櫸頭＋左突歸+牆規。', '白天開放', '免費', NULL, 4.1, '(08)2328638', '2025-05-29 07:08:48')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_371020000A_000377', '陳詩吟洋樓', (SELECT category_id FROM Category WHERE name = '林業歷史與人文' LIMIT 1), (SELECT city_id FROM City WHERE name = '金門縣' LIMIT 1), '金門縣金城鎮珠浦東路44號', 24.43153, 118.31773, 'https://kinmen.travel/image/1664/640x480', '陳詩吟洋樓為清朝末年(1903)金門高坑人陳詩吟前往新加坡、印尼經商致富，於1932年間，斥資30,000銀元建屋。於2006年被列為縣定古蹟。', '白天開放', '免費', NULL, 3.9, '(08)2328638', '2026-04-10 08:30:39')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_376440000A_000001', '山溪地高爾夫球場', (SELECT category_id FROM Category WHERE name = '戶外體驗' LIMIT 1), (SELECT city_id FROM City WHERE name = '新竹縣' LIMIT 1), '新竹縣關西鎮玉山里2鄰13號', 24.76261969, 121.2129152, 'https://travel.hsinchu.gov.tw/admin/Content/Upload/image/20250120/2901ee53-d7a3-4cfc-b023-bd4b0235352a.jpg', '山溪地高爾夫球場位於新竹縣關西鎮，本身依山傍水，美景自成，秋冬時期能完全阻隔東北季風，擁有風小、霧少及天候佳等優點，一再受球友們的認同及好評。山溪地高爾夫俱樂部是一座融合大自然風貌與花園景觀的優美球場，佔地76公頃，設計上採南洋風花園式18洞標準球場，在每個球洞兩側分別種植不同種類的樹木，會館洋溢峇里島風，兼顧自然保育與人文開發的平衡。亦開放夜間球場，為嚮往鄉間森林、吸取芬多精的最佳去處。', '預約制', '依店家公告', NULL, 4.1, '(03)5476288', '2025-05-27 04:24:50')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_376440000A_000002', '老爺關西高爾夫球場', (SELECT category_id FROM Category WHERE name = '戶外體驗' LIMIT 1), (SELECT city_id FROM City WHERE name = '新竹縣' LIMIT 1), '新竹縣關西鎮玉山里一鄰赤柯山1號', 24.7523074258106, 121.197451462116, 'https://travel.hsinchu.gov.tw/admin/Content/Upload/image/20250522/61b3a28e-c7b3-4968-919c-bb01de04d831.jpg', '老爺關西高爾夫球場擁有戰略型的18洞球場，每一洞都經過巧妙佈局的設計，是當今美國及亞洲地區當紅設計師 J.Michael Poellot 的作品，設施規劃完全符合國際水準，連灌溉系統、草皮鋪蓋、碼距標示系統等，都經過精心設計。此外，老爺關西高爾夫俱樂部的果嶺坡度則變化繁複，不論是初學者或專業好手，皆能享受揮桿的快感。', '預約制', '依店家公告', NULL, 4.1, '(03)5476331', '2025-05-27 04:22:47')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_376440000A_000003', '旭陽高爾夫球場', (SELECT category_id FROM Category WHERE name = '自然景觀' LIMIT 1), (SELECT city_id FROM City WHERE name = '新竹縣' LIMIT 1), '新竹縣關西鎮南新里新城段100號', 24.7475032806396, 121.183479309082, 'https://travel.hsinchu.gov.tw/admin/Content/Upload/image/20241121/ea17034f-95f4-4c15-b0b4-0459d62d1472.jpg', '座落於關西的旭陽高爾夫球場，隱身於幽靜的山林之中，運用「杉木群」創造出一條蜿蜒美麗的迎賓綠蔭大道，蓊鬱的樹林與翠綠的球道自然地融合，風貌樸實，林相自然，隨時可見成群的白鷺鷥翩然飛舞，是一個讓您可以感覺全然歸屬的自然天地。 這座由歐美及日本高球大師設計的18洞球場，球道長7128碼，有著美式球場的大氣和日式球場的細膩，巧妙地運用自然景觀的隔局，使打球饒富樂趣及變化，群山層疊圍繞，展現獨樹一格的視野與寧靜，讓您擊球專注不受干擾，輕鬆享受揮桿的暢快。 旭陽高爾夫球場的主體建築是一棟洋溢著西班牙建築風格的會館，紅瓦白牆、高塔鐘樓，淡淡散發著18世紀莊園素樸內斂的氣質，會館內部大量運用自然灑落的光線與原木色系裝潢，氣度朗朗、明亮舒適，讓您身處其中同時享受尊榮與閒適。特別精心為球友量身打造的淋浴設備、自然光落地景觀大湯池，充滿日式簡約雅致的風格設計，讓您在揮汗擊球後身心得以完全的放鬆。位於會館二樓有著球場最棒視野的景觀餐廳，大片採光的玻璃窗景，俯瞰球場全貌盡收綠意美景，備有大小型貴賓廳滿足您各種聚會宴客的需求。', '預約制', '依店家公告', NULL, 4.1, '(03)5476568', '2025-05-27 04:20:42')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_376470000A_000001', '田尾公路花園', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '彰化縣' LIMIT 1), '彰化縣田尾鄉彰化縣田尾鄉民族路一段156號', 23.89598, 120.5318, 'https://tourism.chcg.gov.tw/upload/27/2024073008452916934.jpg', '當稻田轉換成一畝畝花田，就來到素有花卉故鄉美譽的田尾鄉，這裡是全台灣最大的花卉生產地區，也是最大的植栽販售中心，以園藝產業為主題，形成了世界各地都無法複製的公路花園，聚集多達140多家的園藝行、景觀庭園等，交響譜出最廣袤多采、四季繽紛的超級花博會。　尤其，田尾花農和業者們各各功力深厚，是無數流行園藝的操盤手，無論是想「捻花惹草」，尋找最潮的花樣，還是想「走馬看花」，賞花、買植栽、休憩觀光，抑或要深入園藝這門學問，這座跨村落的花鄉王國都讓人有無窮的探索樂趣。', '08:00-18:00', '部分設施另計', NULL, 4.4, '(04)8832626', '2025-08-28 17:00:52')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_376470000A_000004', '八卦山大佛風景區', (SELECT category_id FROM Category WHERE name = '林業歷史與人文' LIMIT 1), (SELECT city_id FROM City WHERE name = '彰化縣' LIMIT 1), '彰化縣彰化市彰化縣彰化市溫泉路31號', 24.07848, 120.5488, 'https://tourism.chcg.gov.tw/upload/27/2025042314275293709.jpg', '八卦山大佛盤座在八卦山頭，低目慈眉看照著彰化，總讓快要接近彰化市和在地人熟悉地仰望，已超越宗教，成為彰化縣的重要地標，更吸引絡繹不絕的遊客，是彰化必訪勝地。　法相莊嚴肅穆的大佛竣工於1961年，曾是台灣十大熱門旅遊景點，被納入遠足、畢旅行程，從南到北，幾乎人人都有張和大佛合影紀念照片，交織許多記憶，增加歷史的厚度。　八卦山大佛風景區逾半世紀逐步形成，除了莊嚴的釋迦摩尼佛像，周邊還有豐富的遊憩資源，進入大佛風景區，首入眼簾是巍峨牌樓、連接「參佛道」，階梯盡頭似是一片天空點綴樹木，而兩旁卅二尊觀音法雕石像，引領執拾而上、沉澱心靈，走著走著，當視覺往右往挪移，乍見22公尺高的巨大釋迦牟尼佛盤坐蓮花座，讓人不由得歡喜讚嘆，大佛之大，也曾是亞洲第一。', '08:30-17:30', '免費', NULL, 4.5, '(04)7222290', '2025-05-21 16:38:32')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_376470000A_000006', '田中森林公園', (SELECT category_id FROM Category WHERE name = '自然景觀' LIMIT 1), (SELECT city_id FROM City WHERE name = '彰化縣' LIMIT 1), '彰化縣田中鎮彰化縣田中鎮中南路二段187號', 23.85306, 120.5877, 'https://tourism.chcg.gov.tw/upload/27/2014120516400072424.jpg', '環境清幽的鼓山寺、林蔭扶疏的田中森林公園、公園內蝶兒飛舞、鳥鳴吟吟，豐富的生態景觀資源，更有登山步道蜿蜒穿行在山嶺線上、自行車道彎延穿行山林、田野之間，構成了田中森林遊樂區，煩擾工作之餘，想登山健行、遠眺賞景、森林浴、休憩、或者來趟自然生態之旅，到這兒來準沒錯！', '全天開放', '免費', NULL, 4.1, '(04)92580525', '2023-05-17 09:58:47')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_376490000A_000001', '雲林布袋戲館(開放日期請見粉絲專頁)', (SELECT category_id FROM Category WHERE name = '林業歷史與人文' LIMIT 1), (SELECT city_id FROM City WHERE name = '雲林縣' LIMIT 1), '雲林縣虎尾鎮雲林縣虎尾鎮林森路一段498號', 23.7093, 120.43356, 'https://k241.noon360.com/public/upload/StoreCover/220223023134430252UEWYU.jpg', '戲裡乾坤，彈指話說千古事前身質樸雅致的虎尾郡役所，於2001年正式公告為歷史建築，並化身在地文化氣息濃厚的布袋戲館。館內詳盡介紹布袋戲各派別、角色、文化故事和歷史沿革，來自各國的經典戲偶角色；蘊藏著古早記憶的皮影戲偶及金碧輝煌的戲臺，以及備受好評的互動式表演，皆適合與長輩同遊，感受布袋戲演藝的時光隧道！', '三-日10:00-18:00', '免費', NULL, 4.3, '(05)6313080', '2026-03-05 10:20:59')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_376570000A_000052', '正濱漁港色彩屋', (SELECT category_id FROM Category WHERE name = '自然景觀' LIMIT 1), (SELECT city_id FROM City WHERE name = '基隆市' LIMIT 1), '基隆市中正區正濱路', 25.1524181, 121.7691051, 'https://klctb-ws.klcg.gov.tw/001/Upload/tour/445/12546/423/pic/0b800ea8-0e06-4c68-80f2-12e9ad8c4d04.jpg', '-景點簡介-	色彩斑斕的小屋與天海相映充滿童趣，彷彿走進了義大利五漁村，又充滿著濃濃的台灣風情，正濱漁港在日治時期曾為台灣第一大港，於西元 1934 年由日本人建造，現在仍能從港灣的風貌中，窺見昔日充滿商船魚貨的繁榮樣貌，如今搖身一變成為五彩繽紛充滿童趣漁村港口，已是相當熱門的休閒碼頭，而位於漁港旁的色彩屋更是許多遊客喜愛拍照的著名地標。-景點特色-五顏六色的色彩屋就像是孩子手上的調色盤，可可愛愛又溫暖的色調，港灣裡的漁船隨風輕輕搖晃，水波輕輕閃耀，這裡的時光像是一首輕快的老歌，小小的港灣溫柔的懷抱歲月長河裡的繁盛與靜好，港邊老建築的活力重生，色彩斑斕的佇立，為漁港帶來新的脈動與能量。-推薦玩法-愛拍照的朋友假如想尋找最佳機位，色彩屋最佳拍照點位於對岸正濱路觀景平台，白日晴天無雲時拍照可拍出水面的五彩倒影，日落時分隨著天光展現出深邃的藍，隨著點點燈火亮起，夜晚的藍調時刻也相當令人難忘。附近還有全台唯一的「台畜公車亭」，以熱狗堡為主題，繽紛可愛的美式配色受到旅客喜愛，在公車亭拍照，能將色彩屋也一起入鏡，是拍照不可錯過的場景之一。-周邊推薦-	離開正濱漁港色彩屋後，可以就近到阿根納造船廠、八尺門拍照遊覽，或到和平島觀光魚市品嚐美食。', '全天開放', '免費', NULL, 4.5, '(02)23491500', '2025-12-22 00:00:00')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_376570000A_000055', '阿根納造船廠', (SELECT category_id FROM Category WHERE name = '林業歷史與人文' LIMIT 1), (SELECT city_id FROM City WHERE name = '基隆市' LIMIT 1), '基隆市中正區正濱路 116 巷 75 號(造船廠內部空間禁止進入)', 25.1538926, 121.7695873, 'https://klctb-ws.klcg.gov.tw/001/Upload/tour/445/12546/346/pic/c37a8039-8dc8-4144-8bb6-82021eda19e5.jpg', '-景點簡介-阿根納造船廠本體遺構於日治時期,曾是金瓜石煤礦運輸據點,戰後轉為美國公司經營遊艇製造,如今裸露的鋼筋水泥散發出頹廢美感,還吸引好萊塢明星克里斯·伊凡(Chris Evans)前來取景拍攝廣告。-景點特色-阿根納造船廠原為 1919 年設立的八尺門貯炭場,日治時期作為金瓜石礦物運輸的重要裝運碼頭,戰後由中華民國政府接收,持續使用至 1962 年。1966 年起由美商阿根納造船廠承租,用於製造遊艇與帆船,直至 1987 年停業。在 2016 年,阿根納造船廠遺構登錄為基隆市歷史建築,廠區遺留的龐大鋼筋混凝土結構因獨特的樣貌吸引遊客前來一訪。-推薦玩法-建議在清晨或午後造訪阿根納造船廠,順著外圍步道欣賞建築結構,陽光灑落在斑駁牆面與鋼骨之間,營造出獨特的光影氛圍。傍晚時分,更能捕捉夕陽穿過建築的絕美瞬間,是攝影愛好者不容錯過的拍攝亮點。從和平橋上拍攝,可以得到最美的光線,同時將造船廠的建築結構完整呈現。拍攝時請留意安全與現場標示,勿進入廠區內部。', '全天開放', '免費', NULL, 4.1, '(02)24224170', '2025-12-22 00:00:00')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_376570000A_000056', '基隆塔', (SELECT category_id FROM Category WHERE name = '自然景觀' LIMIT 1), (SELECT city_id FROM City WHERE name = '基隆市' LIMIT 1), '基隆市中正區正義里義二路128號', 25.1328033, 121.7470181, 'https://klctb-ws.klcg.gov.tw/001/Upload/tour/445/12546/1125/pic/ee0d4073-66e4-4095-a5e1-8202f53a66f3.jpg', '-景點簡介-基隆塔以港區的「橋式起重機」為設計理念,巧妙地將基隆港特色融合,並添加亮眼的橘色為雨都基隆增添亮麗的色彩。不僅是基隆的地標,登上 64 公尺高的空中廊道,更可以俯瞰基隆的山海景色與港區美景。-景點特色-基隆塔擁有約 87 公尺長、64 公尺高的空中廊道,將山腳下的信二防空洞、山丘上的中正公園一一串聯,廊道兩旁的視野遼闊,可以俯瞰港灣與山海景色。空中廊道下方的崆 House K 結合書香與美食文化,每一格的窗景座位區都有不同的視角能夠飽覽基隆美景;四樓的遠見人文空間讓民眾閱覽精選書籍的同時,眺望遠處的風景。除了室內空間擁有不少亮點之外,基隆塔還與台灣人氣插畫家Duncan 合作,從入口處到頂樓周圍都能看見 Duncan 的身影,是兼具打卡、賞景與文化體驗的多元景點。-推薦玩法-推薦你一條一次飽覽山景及防空洞特殊景觀抵達基隆塔的路徑,從「信二防空洞」步行上或是搭乘電梯即可抵達扇形廣場,沿線欣賞基隆港與山海景色。登塔後可前往崆 House K 喝杯咖啡、選本書感受港都人文氛圍,也別錯過與插畫角色DUNCAN 拍照打卡的趣味亮點!-周邊推薦-在遊玩基隆塔後,延著空中廊道就可以抵達主普壇及中正公園;或著順遊鄰近的信二防空洞......等景點,完整感受基隆的山海美景與文化特色!', '二-日10:00-22:00', '免費', NULL, 4.6, '(02)24287664', '2025-12-22 00:00:00')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_376600000A_000001', '福康安紀功碑', (SELECT category_id FROM Category WHERE name = '林業歷史與人文' LIMIT 1), (SELECT city_id FROM City WHERE name = '嘉義市' LIMIT 1), '嘉義市東區嘉義公園內', 23.48344, 120.46406, 'https://travel.chiayi.gov.tw/FileDownload/TravelInformation/Big/20260311192907985311568.jpg', '乾隆皇帝御製的褒揚功碑福康安紀功碑的名氣很大，將石碑豎立於石龜上，相當壯觀，在中國到處可以見到用石龜作為台基的石碑，不過在台灣卻是罕見的，只有台南等地留有幾塊，不只是物稀為貴，更重要的，此碑牽引出一段台灣重要的歷史 ─ 林爽文事變，尤其是諸羅縣因此事件奉皇帝賜名為「嘉義」，為全台地名唯一由皇帝親賜的特例。乾隆 51 年 (1786) ，林爽文在彰化舉兵起事，殺死彰化知縣，南下攻陷諸羅 ( 嘉義 ) 縣及鳳山縣，一時全台騷亂。由於台灣總兵柴大紀奮勇作戰，不但保衛住台南府城，又於乾隆 52 年 (1787) 正月收復諸羅縣城。而林爽文部眾在重整後，繼續圍攻諸羅城，戰事慘烈，情勢岌岌可危。同年十月，乾隆調派履立戰功的福康安將軍率兵增援台灣，果將林爽文擊敗，解除了諸羅城之圍。事後已諸羅城軍民守城義勇可嘉，特家地名改為嘉義。乾隆 53 年 (1788) 皇帝御製十座紀工碑石與龜座，以褒揚福康安之戰功，其中四座全刻滿文，四座全刻漢文，二座漢滿文合刻，而漢滿文合刻的一座預定立於嘉義，其餘九座立於台南府城。碑石吉龜座在廈門雕刻完成，運抵台南府城港口卸貨時，其中一龜座不慎掉入港內，乃另以砂岩仿造，至於嘉義。碑座經數次遷移，最後安置現址。 ( 掉落港內的龜座於 1911 年被台南漁民撈起，供奉在台南保安宮 ) 。福康安紀功碑小檔案尺寸：石碑高 310 公分，寬 143 公分形式：額刻御製，雙龍文飾，邊框飾龍紋，滿和文字合壁。景點建造：清乾隆 53 年 ( 西元 1788 年 )', '全天開放', '免費', NULL, 3.8, '(05)2294593', '2026-03-25 18:00:15')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_376600000A_000002', '丙午震災紀念碑', (SELECT category_id FROM Category WHERE name = '林業歷史與人文' LIMIT 1), (SELECT city_id FROM City WHERE name = '嘉義市' LIMIT 1), '嘉義市東區嘉義公園內', 23.48381, 120.46456, 'https://travel.chiayi.gov.tw/FileDownload/TravelInformation/Big/20260323193338212978545.jpg', '災後重建的軌跡～台灣地震頻傳，在日治時代曾發生多次烈震。明治 39 年 (1906)3 月 17 日黎明六時發生大地震 ( 全震動時間長達四分多鐘 ) ，震央位於民雄與梅山之間，人畜傷亡頗多，建物毀損嚴重，大小餘震不斷，相繼壓死一千兩百多人，嘉義市街建築物大半毀於地震。災後行政當局趁機規劃市區改道計劃，今之嘉義市區奠基於此。此次地震立有「震災記」石碑，可能為全台首座地震紀念碑，係由莊伯容撰文。二戰後遭改名為「青年育樂中心」，民國 90 年 3 月，文化局加以恢復。景點建造：    刻立：明治 39 年 ( 西元 1906 年 ) 復原：民國 90 年 3 月', '全天開放', '免費', NULL, 3.8, '(05)2294593', '2026-03-25 18:00:02')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_376600000A_000003', '十二門古砲', (SELECT category_id FROM Category WHERE name = '林業歷史與人文' LIMIT 1), (SELECT city_id FROM City WHERE name = '嘉義市' LIMIT 1), '嘉義市東區嘉義公園內', 23.48381, 120.46531, 'https://travel.chiayi.gov.tw/FileDownload/TravelInformation/Big/20260323193241154557051.jpg', '迷樣的重量級古砲遺跡～這十二門古砲系於西元1975年移置現地，其中一門砲管鑄字清晰可見，內容為：「嘉慶十二年秋，奉閩浙總部堂阿，福建巡撫部長，鑄造台協水師左營大砲，一位重一千斤」等字樣。其古砲來源尚無資料可稽，可能與嘉義出身的水師提督王得祿有關，也可能是原配置在東、南、西北城門的古砲。景點建造：    鑄造於清嘉慶 12 年 ( 西元 1807 年 )', '全天開放', '免費', NULL, 3.8, '(05)2294593', '2026-03-25 17:59:51')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_379000000A_000010', '陽明山溫泉區_小油坑', (SELECT category_id FROM Category WHERE name = '自然景觀' LIMIT 1), (SELECT city_id FROM City WHERE name = '台北市' LIMIT 1), '台北市北投區', 25.17669, 121.54683, 'https://www.travel.taipei/content/images/attractions/63396/640x480_attractions-image-uyx4nvg7e0avmy8a1n-vzq.jpg', '小油坑為一處後火山活動地質景觀區，由陽金公路的小觀音站右轉可達觀景步道，以「後火山作用」所形成之噴氣孔、硫磺結晶、溫泉及壯觀的崩塌地形最具特色。而在這裡的眺望平台還可遠眺竹子山、大屯山、七星山與小觀音山等火山錐體，以及金山海岸、停車場等。喜歡觀察植物的遊客，還可以用十幾分鐘的時間，一遊附近的箭竹林步道，觀察箭竹林、芒草原和火山植物。', '依園區公告', '免費', NULL, 4.5, '(02)28617024', '2024-03-14 13:54:15')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_379000000A_000011', '新北投溫泉商圈', (SELECT category_id FROM Category WHERE name = '戶外體驗' LIMIT 1), (SELECT city_id FROM City WHERE name = '台北市' LIMIT 1), '台北市北投區', 25.137, 121.50853, 'https://www.travel.taipei/content/images/attractions/292627/640x480_attractions-image-mml2jsjbhugzj-dksmkigw.jpg', '北投溫泉從日據時代便有盛名，喜愛泡湯的日本人自然不會錯過，瀧乃湯、星乃湯、鐵乃湯就是日本人依照溫泉的特性與療效給予的名稱，據說對皮膚病、神經過敏、氣喘、風濕等具有很好的療效，也因此成為了北部最著名的泡湯景點之一。新北投溫泉的泉源為大磺嘴溫泉，泉質屬硫酸鹽泉，PH值約為3~4之間，水質呈黃白色半透明，泉水溫度約為50-90℃，帶有些許的硫磺味 。目前北投的溫泉旅館、飯店、會館大部分集中於中山路、光明路沿線以及北投公園、地熱谷附近，每一家都各有其特色，多樣的溫泉水療以及遊憩設施，提供遊客泡湯養生。鄰近的景點也是非常值得造訪，例如北投溫泉三寶的吟松閣、星乃湯、瀧乃湯以及記錄臺灣第一家溫泉旅館的天狗庵史蹟公園，都有著深遠的歷史背景。而北投公園、北投溫泉博物館、北投文物館、地熱谷等，更是遊客必遊的景點，來到北投除了可以讓溫泉洗滌身心疲憊，也可以順便深入了解北投溫泉豐富的人文歷史。', '依店家公告', '泡湯另計', NULL, 4.5, '(02)28955418', '2024-11-04 17:32:06')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_395000000A_000466', '南鯤鯓代天府', (SELECT category_id FROM Category WHERE name = '林業歷史與人文' LIMIT 1), (SELECT city_id FROM City WHERE name = '台南市' LIMIT 1), '台南市北門區鯤江976號', 23.28647, 120.14159, 'https://www.twtainan.net/image/109669/640x480', '全臺規模最大的王爺信仰中心', '依廟方公告', '免費', NULL, 4.4, '(06)7863711', '2025-08-22 17:31:03')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_395000000A_000467', '東隆宮文化中心', (SELECT category_id FROM Category WHERE name = '林業歷史與人文' LIMIT 1), (SELECT city_id FROM City WHERE name = '台南市' LIMIT 1), '台南市北門區三光里三寮灣127-3號', 23.23833, 120.1118, 'https://www.twtainan.net/image/18138/640x480', '來到北門區三寮灣，不管從哪個方向，遠遠的都可以看到七樓高的「東隆宮文化中心」，在小漁村內顯得格外華麗，如果喜歡看迎神賽會，熱愛祭典的氣氛，來到此處一定會非常開心。', '依廟方公告', '免費', NULL, 4.1, '(06)7850355', '2024-01-09 16:06:59')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_397000000A_000010', '中都愛河濕地公園', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '高雄市' LIMIT 1), '高雄市三民區同盟三路與十全三路交叉處', 22.64655, 120.28653, 'https://khh.travel/image/889/640x480', '串起高雄城市生態綠廊的中都愛河濕地公園座落於愛河南側的十全與九如路之間，全長約2.5公里，佔地達七千餘平方公尺。', '全天開放', '免費', NULL, 4.2, '(07)7995678', '2021-05-03 11:40:46')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_A15010200H_000001', '目斗嶼', (SELECT category_id FROM Category WHERE name = '自然景觀' LIMIT 1), (SELECT city_id FROM City WHERE name = '澎湖縣' LIMIT 1), '澎湖縣白沙鄉目斗嶼', 23.7841, 119.602, 'https://www.penghu-nsa.gov.tw/FileDownload/TravelInformation/NotSet/20140811141644331.jpg', '目斗嶼與其南側的吉貝嶼相隔7公里。全島周長843公尺，面積僅0.0244平方公里，是一個迷你小島，島上以目斗嶼燈塔聞名。由於附近有許多暗礁，以往常發生船難，所以在清代光緒年間設立目斗嶼燈塔，為船隻指引方向，至今已超過百年。目斗嶼燈塔高40公尺，黑白相間的塔身矗立在黑褐色的岩礁上，自然散發一股巍峨的氣勢。目斗嶼與其南側的吉貝嶼相隔7公里。全島周長843公尺，面積僅0.0244平方公里，是一個迷你小島，島上以目斗嶼燈塔聞名。由於附近有許多暗礁，以往常發生船難，所以在清代光緒年間設立目斗嶼燈塔，為船隻指引方向，至今已超過百年。目斗嶼燈塔高40公尺，黑白相間的塔身矗立在黑褐色的岩礁上，自然散發一股巍峨的氣勢。 由玄武岩組成的目斗嶼，極具原始風貌，黑色的岩石讓島的四周立體感十足且層次分明，激起浪花朵朵，透出一份豪壯之氣。從吉貝嶼前往目斗嶼的航程上，由於水域較淺，充足的陽光讓此海域擁有多樣化的海洋生物，當陽光灑落下來，光芒輕快地跳躍在清澈碧綠的水面上，海底世界一覽無遺。', '依船班天候', '船票另計', NULL, 4.1, '(06)9933082', '2023-10-30 15:08:01')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_A15010200H_000002', '吉貝嶼', (SELECT category_id FROM Category WHERE name = '自然景觀' LIMIT 1), (SELECT city_id FROM City WHERE name = '澎湖縣' LIMIT 1), '澎湖縣白沙鄉吉貝嶼', 23.73025, 119.60246, 'https://www.penghu-nsa.gov.tw/FileDownload/TravelInformation/NotSet/20170308150354509610354.jpg', '吉貝嶼全島面積約3.1平方公里，海岸線長約13公里，是北海最大的島嶼，國內最熱門的旅遊景點。全島地勢東高西低，由海積地形組成的美麗沙灘及沙嘴，為本島最大的地形特色，沙灘位本島西南，由西崁山向南延伸；在沙灘的盡頭，因受海流影響而形成伸入海中的沙嘴，全長約800公尺，最寬處約200公尺，島的四周人工分散設置許多大小石滬，全盛時期達二百餘口，目前僅剩88口，島嶼距離赤崁約5浬，航程約20分鐘。 吉貝嶼全島面積約3.1平方公里，海岸線長約13公里，是北海最大的島嶼，國內最熱門的旅遊景點。全島地勢東高西低，由海積地形組成的美麗沙灘及沙嘴，為本島最大的地形特色，沙灘位本島西南，由西崁山向南延伸；在沙灘的盡頭，因受海流影響而形成伸入海中的沙嘴，全長約800公尺，最寬處約200公尺，島的四周人工分散設置許多大小石滬，全盛時期達二百餘口，目前僅剩88口，島嶼距離赤崁約5浬，航程約20分鐘。 因為吉貝嶼不僅是澎湖北方的漁場之一，由於潮差甚大且擁有廣大的潮間帶，早期的先民長期觀察魚類生態並利用潮差來捕魚，就地利用周邊的玄武岩與珊瑚礁，趁著每天退潮時堆砌石滬捕魚。根據記載，在清朝乾隆年間徵收「滬稅」時，吉貝便擁有1口大滬、4口小滬，可見石滬的建造遠在清乾隆以前便有了。 吉貝嶼海域石滬密佈，目前僅存的88座，佔全縣580多座石滬的近七分之一，退潮時，從當地小地名魟灣仔可以涉水走到西北方的過嶼。魟灣仔東西兩側沿岸石滬密集，數量約佔吉貝石滬的一半（約40個）。這種居民利用潮間帶，以玄武岩堆砌成的捕魚陷阱，是吉貝嶼最具特色的一項人文景觀。 追星景點 紅極一時的電視偶像劇「海豚灣戀人」，澤亞(許紹洋飾)長大後，在海豚灣邂逅易天邊(張紹涵飾)的地方就是吉貝沙尾。 『聽過海豚的傳說嗎？傳說中，海豚曾經銜著一枚鋼戒幫助一對失散了的戀人重新相聚，從此變成了愛情的守護神！ 在天邊的海豚灣，流傳著一段愛與傳說的故事！ 』 本劇播出時，帶動了很多的粉絲來到此地追星，易天邊與徐澤亞長大後第一次相遇的船屋、易天邊家的麵店還有海豚灣公車站牌都是粉絲們鏡頭捕捉的焦點，你是不是也是其中的一個呢？來到吉貝嶼，除了在吉貝沙尾感受沙灘、幻想船屋的場景外，也別忘了進入社區尋找劇中女主角易天邊的家哦，如果你有拍照，歡迎跟我們分享哦！ 另外，療傷系歌手辛曉琪「遺忘」MTV影片也是在吉貝拍攝，澎湖夏天特有的嬌艷、多彩，都在影片中。深受年輕人喜愛的「大仁哥」－陳柏霖與柯有倫為統一於2006年拍的「7-ELEVEN形象廣告」，兩個人騎著摩托車，而天空正飄過來白雲一朵，以及2人脫下短褲衝入清澈見底海水的畫面，都是在吉貝。', '依船班天候', '船票另計', NULL, 4.4, '(06)9933082', '2023-10-30 15:08:29')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_A15010200H_000003', '姑婆嶼', (SELECT category_id FROM Category WHERE name = '生態觀察與動植物' LIMIT 1), (SELECT city_id FROM City WHERE name = '澎湖縣' LIMIT 1), '澎湖縣白沙鄉姑婆嶼', 23.7157, 119.5563, 'https://www.penghu-nsa.gov.tw/FileDownload/TravelInformation/NotSet/20230209120828543956.jpg', '姑婆嶼位於白沙的西北方、吉貝嶼的西南方，為一座玄武岩構成的方山台地，南、北長約1公里，是澎湖群島中最大的無人島。全島露出許多多孔狀玄武岩，表層覆蓋著富含鐵質的石英砂岩層，對比強烈，在澎湖各島不同地質中是個異數。姑婆嶼位於白沙的西北方、吉貝嶼的西南方，為一座玄武岩構成的方山台地，南、北長約1公里，是澎湖群島中最大的無人島。全島露出許多多孔狀玄武岩，表層覆蓋著富含鐵質的石英砂岩層，對比強烈，在澎湖各島不同地質中是個異數。 島上北面方山台地上建有一座英船的遇難紀念碑，東側為丁香魚場、東南側海域有美麗的珊瑚群、北側則是最著名的紫菜盛產地；每年農曆春節的前後，赤崁村會依姑婆嶼紫菜生長的情形，辦理大規模的採收活動，赤崁村公廟龍德宮管委會依據每戶人家男丁人口數分丁份收丁口錢作為登島採收的權利。澎湖島礁多，冬季風大浪大，澎湖的野生紫菜得天獨厚產量又多，在嚴寒冬季為漁民帶來不少收益。 姑婆嶼名稱的由來，有許多的傳說與聯想。據說在很久以前，村莊裡有一位少女，已有相戀多年的男友；但卻遭到父母反對，並強逼其另嫁良人。柔弱的少女，為了反抗父母的逼婚和證明其堅貞的愛情，便與情郎相偕離家出走到澎湖北海的無人島落腳；兩人以天地為證，以山海為誓，在那小島上共渡餘生。據說，她的晚輩來探望她時，均以姑婆尊稱；另一版本則是這位女孩為信守愛情的承諾，自我放逐至無人島孤獨終老，因早期未婚而終老者習俗稱為姑婆，這座無人島也被稱為姑婆嶼。但不論如何，當這個用一生信守愛情的故事口耳相傳至今的同時，姑婆的故事，也就成為這座無人島的美麗的傳說了！', '依船班天候', '船票另計', NULL, 3.8, '(06)9933082', '2023-10-30 15:40:19')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_A15010500H_002657', '白沙港', (SELECT category_id FROM Category WHERE name = '自然景觀' LIMIT 1), (SELECT city_id FROM City WHERE name = '連江縣' LIMIT 1), '連江縣北竿鄉連江縣北竿鄉白沙村 （北竿主要港口，出入北竿島的交通中心）', 26.20531, 119.96881, 'https://www.matsu-nsa.gov.tw/api/uploads/attractions/dfeda63b66ff4a1cbe37c1a6c5cef003.jpg', '白沙港位於北竿島東側，是北竿最重要的港口與對外交通樞紐，連接南竿、莒光與東引等航線。港灣三面環山、地形穩定，具備良好的避風特性，也是旅客踏上北竿的第一個印象。周邊生活機能完善，鄰近村落、商店及遊客中心，讓旅客能迅速補給與規劃行程。此外，港區亦是欣賞漁船往返、海面光影與北竿日常風景的優質位置。', '全天開放', '免費', NULL, 3.9, '(08)3656531', '2026-04-24 17:29:39')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

INSERT INTO Attraction
    (attraction_id, name, category_id, city_id, address, lat, lon, image_url,
     description, opening_hours, ticket_info, website_url, rating, phone, source_updated_at)
VALUES
    ('Attraction_A15010500H_002721', '八八坑道', (SELECT category_id FROM Category WHERE name = '林業歷史與人文' LIMIT 1), (SELECT city_id FROM City WHERE name = '連江縣' LIMIT 1), '連江縣南竿鄉連江縣南竿鄉復興村 （位於馬祖酒廠後方，沿指標即可抵達入口）', 26.160305, 119.9532471, 'https://www.matsu-nsa.gov.tw/FileArtPic.ashx?id=2472&amp;w=1280&amp;h=960', '八八坑道位於南竿復興村，是馬祖酒廠最具特色的天然儲酒坑道，同時也是馬祖戰地文化的重要遺跡之一。坑道原為軍事戰備所建，後因其恆溫、恆濕與穩定的地底環境，被轉用為老酒與陳高的熟成空間。步入坑道，花崗岩壁微涼濕潤，兩側整齊排列的酒甕氣味濃郁，呈現酒香、歷史與軍事文化交織的獨特體驗，是來到南竿必訪的經典景點。', '08:40-17:00', '免費', NULL, 4.2, '(08)3622820', '2026-01-20 17:06:46')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    category_id = VALUES(category_id),
    city_id = VALUES(city_id),
    address = VALUES(address),
    lat = VALUES(lat),
    lon = VALUES(lon),
    image_url = VALUES(image_url),
    description = VALUES(description),
    opening_hours = VALUES(opening_hours),
    ticket_info = VALUES(ticket_info),
    website_url = VALUES(website_url),
    rating = VALUES(rating),
    phone = VALUES(phone),
    source_updated_at = VALUES(source_updated_at),
    is_deleted = FALSE;

COMMIT;
