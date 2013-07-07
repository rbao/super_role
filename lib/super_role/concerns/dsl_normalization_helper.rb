module SuperRole
  module DslNormalizationHelper
    extend ActiveSupport::Concern

    private
      def arrayify_then_stringify_items(object)
        Array(object).map { |i| i.to_s }
      end
  end
end