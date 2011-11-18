require 'test_helper'

class BuilderPhpTestCase < Test::Unit::TestCase
  def new_config(config={})
    Travis::Worker::Builders::Php::Config.new(config)
  end

  def config_any_instance
    Travis::Worker::Builders::Php::Config.any_instance
  end

  def new_commands(config={})
    Travis::Worker::Builders::Php::Commands.new(config)
  end

  def commands_any_instance
    Travis::Worker::Builders::Php::Commands.any_instance
  end
end

class BuilderPhpConfigTests < BuilderPhpTestCase
  def test_config_default_php
    assert_equal('5.3.8', new_config.php)
  end

  def test_config_custom_php
    config = new_config('php' => 'foobar')
    assert_equal('foobar', config.php)
  end

  def test_config_custom_php_as_an_array
    config = new_config('php' => ['foobar'])
    assert_equal('foobar', config.php)
  end

  def test_config_default_script
    assert_equal('phpunit', new_config.script)
  end

  def test_config_custom_script
    assert_equal('foo bar', new_config(:script => 'foo bar').script)
  end
end


class BuilderPhpCommandsTests < BuilderPhpTestCase
  def test_setup_env
    commands_any_instance.expects(:exec).
      with("test -f composer.json", :echo => false).
      once

    commands_any_instance.expects(:exec).
      with("phpenv global 5.3.8").
      once

    new_commands.setup_env
  end

  def test_setup_env_with_other_env_vars
    commands_any_instance.expects(:exec).
      with("test -f composer.json", :echo => false).
      once

    commands_any_instance.expects(:exec).
      with("phpenv global 5.3.8").
      once

    commands_any_instance.expects(:exec).
      with("export FOO=bar").
      once.returns(true)

    new_commands(:env => "FOO=bar").setup_env
  end

  def test_commands_install_dependencies_without_composer
    commands_any_instance.expects(:exec).
      with("test -f composer.json", :echo => false).
      once.returns(false)

    assert new_commands.run_install_dependencies
  end

  def test_commands_install_dependencies_with_composer_without_args
    commands_any_instance.expects(:exec).
      with("test -f composer.json", :echo => false).
      once.returns(true)

    commands_any_instance.expects(:exec).
      with("composer install", :timeout => :install).
      once.returns(true)

    assert new_commands.run_install_dependencies
  end

  def test_commands_install_dependencies_with_composer_with_args
    commands_any_instance.expects(:exec).
      with("test -f composer.json", :echo => false).
      once.returns(true)

    commands_any_instance.expects(:exec).
      with("composer install --foobar", :timeout => :install).
      once.returns(true)

    assert new_commands(:composer_args => '--foobar').run_install_dependencies
  end
end
