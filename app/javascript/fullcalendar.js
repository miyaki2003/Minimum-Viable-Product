import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import bootstrap5Plugin from '@fullcalendar/bootstrap5';
import jaLocale from '@fullcalendar/core/locales/ja';
import interactionPlugin from '@fullcalendar/interaction';

import 'bootstrap/dist/css/bootstrap.min.css';
// import 'bootstrap-icons/font/bootstrap-icons.css';

document.addEventListener('DOMContentLoaded', function() {
  let calendarEl = document.getElementById('calendar');
  if (calendarEl) {
    let calendar = new Calendar(calendarEl, {
      height: "auto",
      plugins: [ interactionPlugin, dayGridPlugin, timeGridPlugin, listPlugin, bootstrap5Plugin ],
      themeSystem: 'bootstrap5',
      locale: 'ja',
      initialView: 'dayGridMonth',
      selectable: true,
      googleCalendarApiKey: 'AIzaSyBEjT2zMm5yB9LYkUawhLf6A9oNt1rRWBA',
      events: {
        googleCalendarId: 'ja.japanese#holiday@group.v.calendar.google.com',
        className: 'event_holiday'
      },
      dayCellContent: function(arg){
        return arg.date.getDate();
      },
      customButtons: {
        CustomButton: {
          text: '設定',
          click: function() {
            window.location.href = 'http://localhost:3000/';
          }
        },
        lineButton: {
          text: 'LINEへ',
          click: function() {
            window.location.href = 'http://localhost:3000/';
          }
        },
      },
      headerToolbar: {
        start: 'prev',
        center: 'title',
        end: 'lineButton CustomButton next'
      },
      footerToolbar: {
        left: 'today',
        center: 'dayGridMonth timeGridWeek listWeek',
        right: 'CustomButton'
      },
      buttonIcons: {
        prev: 'chevron-left',
        next: 'chevron-right'
      },
      buttonText: {
        today: '今月',
        month: '月',
        week: '週',
        list: 'リスト'
      },
      initialView: 'dayGridMonth',
      views: {
        dayGridMonth: {
          titleFormat: { year: 'numeric', month: 'numeric' },
        },
        listMonth: {
          titleFormat: { year: 'numeric', month: 'numeric' },
          listDayFormat: { month: 'numeric', day: 'numeric', weekday: 'narrow' },
          listDaySideFormat: false
        }
      },
      dateClick: function(info) {
        document.getElementById('eventModal').style.display = 'block';
        document.getElementById('eventStart').value = info.dateStr;
      }
    });

    calendar.setOption('windowResize', function() {
      if (window.innerWidth < 768) {
        calendar.changeView('listMonth');
      } else {
        calendar.changeView('dayGridMonth');
      }
    });

    calendar.render();
  }
});
