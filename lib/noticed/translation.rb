
module Translation
  extend ActiveSupport::Concern

  # Returns the +i18n_scope+ for the class. Overwrite if you want custom lookup.
  def i18n_scope
    :notifications
  end

  def translate(key, **options)
    I18n.translate(scope_translation_key(key), **options)
  end
  alias :t :translate

  def scope_translation_key(key)
    if key.to_s.start_with?(".")
      "notifications.#{self.class.name.underscore}#{key}"
    else
      key
    end
  end
end