-- Travel App — placeholder catalog seed
-- Run after schema.sql. Safe to re-run; uses ON CONFLICT where possible.

----------------------------------------------------------------------
-- Continents
----------------------------------------------------------------------
insert into public.continents (lang, name, sort_order) values
  ('en','All',0),
  ('en','Asia',1),
  ('en','Africa',2),
  ('en','Europe',3),
  ('en','North America',4),
  ('en','South America',5),
  ('en','Oceania',6),
  ('ar','الكل',0),
  ('ar','آسيا',1),
  ('ar','أفريقيا',2),
  ('ar','أوروبا',3),
  ('ar','أمريكا الشمالية',4),
  ('ar','أمريكا الجنوبية',5),
  ('ar','أوقيانوسيا',6)
on conflict (lang, name) do nothing;

----------------------------------------------------------------------
-- Popular categories
----------------------------------------------------------------------
delete from public.categories;
insert into public.categories (lang, name, image, sort_order) values
  ('en','Beach',    'https://placehold.co/200x200?text=Beach',    1),
  ('en','Mountain', 'https://placehold.co/200x200?text=Mountain', 2),
  ('en','City',     'https://placehold.co/200x200?text=City',     3),
  ('en','Adventure','https://placehold.co/200x200?text=Adventure',4),
  ('ar','شاطئ',     'https://placehold.co/200x200?text=Beach',    1),
  ('ar','جبل',      'https://placehold.co/200x200?text=Mountain', 2),
  ('ar','مدينة',    'https://placehold.co/200x200?text=City',     3),
  ('ar','مغامرة',   'https://placehold.co/200x200?text=Adventure',4);

----------------------------------------------------------------------
-- Tours
----------------------------------------------------------------------
delete from public.tours;
insert into public.tours
  (lang, title, continent, image, images, overview, distance,
   weather_condition, rating, number_of_reviews, started_price,
   temperature, duration_day, category, extra_price, details, reviews, costs)
values
  ('en','Kyoto Temples','Asia',
    'https://placehold.co/600x400?text=Kyoto',
    array['https://placehold.co/600x400?text=Kyoto+1','https://placehold.co/600x400?text=Kyoto+2'],
    'A scenic tour of the historic temples of Kyoto, including Kinkaku-ji and Fushimi Inari.',
    9500, 'Mild', 4.8, 312, 1200, 22, 5, 'City', 0,
    'Includes guided tour, transport, and lunch.',
    'Highly rated by recent travelers.',
    'Single supplement: $200'),

  ('en','Bali Beaches','Asia',
    'https://placehold.co/600x400?text=Bali',
    array['https://placehold.co/600x400?text=Bali+1','https://placehold.co/600x400?text=Bali+2'],
    'Relax on the white-sand beaches of Bali with snorkeling and surfing day trips.',
    9100, 'Tropical', 4.7, 540, 950, 30, 7, 'Beach', 100,
    'Beach access, snorkel gear, and one boat tour included.',
    'Travelers love the sunsets.',
    'Optional spa: $80'),

  ('en','Swiss Alps','Europe',
    'https://placehold.co/600x400?text=Alps',
    array['https://placehold.co/600x400?text=Alps+1','https://placehold.co/600x400?text=Alps+2'],
    'Cable car rides, alpine villages, and Matterhorn views.',
    6200, 'Cold', 4.9, 215, 1850, 8, 6, 'Mountain', 250,
    'Cable car day passes and one fondue dinner.',
    'Strongly recommended in winter.',
    'Ski rental: $60/day'),

  ('en','Marrakech Souks','Africa',
    'https://placehold.co/600x400?text=Marrakech',
    array['https://placehold.co/600x400?text=Marrakech+1'],
    'Wander the markets and palaces of Marrakech.',
    7800, 'Warm', 4.6, 180, 780, 28, 4, 'City', 50,
    'Guided souk tour and one traditional dinner.',
    'Bustling and colorful.',
    'Camel ride day trip: $90'),

  ('en','Patagonia Trek','South America',
    'https://placehold.co/600x400?text=Patagonia',
    array['https://placehold.co/600x400?text=Patagonia+1'],
    'A multi-day hiking trek through Torres del Paine.',
    13500, 'Cool', 4.9, 98, 2200, 12, 9, 'Adventure', 400,
    'Guided trek, camping gear, and meals.',
    'A bucket list trip for hikers.',
    'Sleeping bag rental: $40'),

  ('ar','معابد كيوتو','آسيا',
    'https://placehold.co/600x400?text=Kyoto',
    array['https://placehold.co/600x400?text=Kyoto+1','https://placehold.co/600x400?text=Kyoto+2'],
    'جولة في المعابد التاريخية في كيوتو.',
    9500, 'معتدل', 4.8, 312, 1200, 22, 5, 'مدينة', 0,
    'تشمل جولة مع مرشد ووسيلة نقل ووجبة غداء.',
    'تقييمات ممتازة من المسافرين.',
    'رسوم إضافية للغرفة الفردية: 200$'),

  ('ar','شواطئ بالي','آسيا',
    'https://placehold.co/600x400?text=Bali',
    array['https://placehold.co/600x400?text=Bali+1','https://placehold.co/600x400?text=Bali+2'],
    'استرخاء على شواطئ بالي مع رحلات الغوص.',
    9100, 'استوائي', 4.7, 540, 950, 30, 7, 'شاطئ', 100,
    'يشمل الوصول إلى الشاطئ ومعدات الغوص ورحلة بحرية واحدة.',
    'يحب المسافرون مشاهدة الغروب.',
    'جلسة سبا اختيارية: 80$');
