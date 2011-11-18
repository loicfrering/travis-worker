module Travis
  module Worker
    module Builders

      module Php
        class Config < Base::Config
          def php
            normalize(super, '5.3.8')
          end

          def composer_exists?
            !!self[:composer_exists]
          end

          def script
            if !self[:script].nil?
              self[:script]
            else
              'phpunit'
            end
          end

          def install
            if !self[:install].nil?
              self[:install]
            elsif composer_exists?
              "composer install #{composer_args}".strip
            else
              nil
            end
          end
        end

        class Commands < Base::Commands
          def initialize(config)
            @config = Config.new(config)
            @config.composer_exists = file_exists?('composer.json')
          end

          def setup_env
            exec "phpenv global #{config.php}"
            super
          end

        end
      end # Php

    end # Builders
  end # Worker
end # Travis

