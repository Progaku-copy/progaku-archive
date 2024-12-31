Rails.application.config.session_store :cookie_store,                           key: '_progaku_archive_session',
                                       expire_after: 6.hours,
                                       http_only: true,
                                       secure: Rails.env.production?, # 本番環境でのみtrue
                                       same_site: Rails.env.production? ? :none : :lax # 本番ではnone、それ以外ではlax