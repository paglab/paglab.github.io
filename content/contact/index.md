---
title: Contact
date: 2022-10-24

type: landing

sections:
  - block: contact
    content:
      title: Contact
      text: |-
        Preferred method of contact is email. 
      email: pag<span class="at-icon" aria-label="@"></span>ls.tum.de
      phone: 0049 81 6171 5013
      address:
        street: Dürnast 9
        city: Freising
        region: Bavaria
        postcode: '85354'
        country: Germany
        country_code: DE
      coordinates:
        latitude: '48.4056883'
        longitude: '11.6904669'
      directions: Enter through the yellow door, pass the seminar room on the left, and then take the stairs to the 2nd Floor
      office_hours:
        - 'Monday 11:00 to 13:00'
        - 'Thursday 11:00 to 13:00'
      appointment_url: 'https://calendly.com/tum-pa'
      #contact_links:
      #  - icon: comments
      #    icon_pack: fas
      #    name: Discuss on Forum
      #    link: 'https://discourse.gohugo.io'
    
      # Automatically link email and phone or display as text?
      autolink: true
    
      # Email form provider
      form:
        provider: netlify
        formspree:
          id:
        netlify:
          # Enable CAPTCHA challenge to reduce spam?
          captcha: true
    design:
      columns: '1'

  - block: markdown
    content:
      title:
      subtitle: ''
      text:
    design:
      columns: '1'
      background:
        image: 
          filename: contact.jpg
          filters:
            brightness: 1
          parallax: false
          position: center
          size: cover
          text_color_light: true
      spacing:
        padding: ['20px', '0', '20px', '0']
      css_class: fullscreen
---
