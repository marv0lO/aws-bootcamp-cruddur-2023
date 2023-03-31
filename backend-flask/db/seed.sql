-- this file was manually created
INSERT INTO public.users (display_name, email, handle, cognito_user_id)
VALUES
  ('Andrew Brown', 'andrewbrown@test.com', 'andrewbrown','MOCK'),
  ('Andrew Bayko', 'bayko@test.com', 'bayko' ,'MOCK'),
  ('Marvin Murithi', 'marv@test.com', 'Marv' ,'MOCK');


INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'andrewbrown' LIMIT 1),
    'This was imported as seed data!',
    current_timestamp + interval '10 day'
  )