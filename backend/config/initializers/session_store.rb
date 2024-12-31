Rails.application.config.session_store :cookie_store,                           key: '_progaku_archive_session',
                                       expire_after: 6.hours,
                                       http_only: true,
                                       secure: Rails.env.production? ? true : false,
                                       same_site: :none