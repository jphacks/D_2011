# frozen_string_literal: true

FactoryBot.define do
  factory :meeting, class: Meeting do
    title { 'sample meeting' }
    start_time { 1_605_020_400 }
    zoom_id { '1234567890' }
    zoom_pass { '3jZ25d' }
    agendas do
      [
        {
          "title": '自己紹介',
          "duration": 120
        },
        {
          "title": '概要',
          "duration": 300
        }
      ]
    end
  end
end

FactoryBot.define do
  factory :missing_zoom_id_meeting, class: Meeting do
    title { 'sample meeting' }
    start_time { 1_605_020_400 }
    zoom_pass { '3jZ25d' }
    agendas do
      [
        {
          "title": '自己紹介',
          "duration": 120
        },
        {
          "title": '概要',
          "duration": 300
        }
      ]
    end
  end
end

FactoryBot.define do
  factory :invalid_meeting, class: Meeting do
    title { 'sample meeting' }
    start_time { '2020/11/12 10:05:23' }
    zoom_pass { '3jZ25d' }
    agendas do
      [
        {
          "title": '自己紹介',
          "duration": '2分'
        },
        {
          "title": '概要',
          "duration": 300
        }
      ]
    end
  end
end
