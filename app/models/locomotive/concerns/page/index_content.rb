module Locomotive
  module Concerns
    module Page

      module IndexContent

        extend ActiveSupport::Concern

        included do

          after_save      :index_content
          after_destroy   :unindex_content

        end

        def content_to_index
          self.editable_elements.where(_type: 'Locomotive::EditableText').map do |element|
            ::ActionController::Base.helpers.strip_tags(element.content)
          end.join(' ')
        end

        def data_to_index
          {
            title:      self.title,
            slug:       self.slug,
            fullpath:   self.fullpath
          }
        end

        private

        def index_content
          # don't index the 404 error page
          return if !search_enabled? || self.not_found?

          # don't block the server app
          Locomotive::SearchIndexPageJob.perform_later(
            self._id.to_s,
            ::Mongoid::Fields::I18n.locale.to_s
          )
        end

        def unindex_content
          # don't index the 404 error page
          return if !search_enabled? || self.not_found?

          # don't block the server app
          Locomotive::SearchDeletePageIndexJob.perform_later(
            self._id.to_s,
            ::Mongoid::Fields::I18n.locale.to_s
          )
        end

      end

    end
  end
end

