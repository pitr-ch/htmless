require 'test_helper'
require 'rails/performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class BenchTest < ActionDispatch::PerformanceTest
  TIMES = 1
  def test_erubis_partials
    TIMES.times { get '/bench/erubis_partials' }
  end

  def test_erubis_single
    TIMES.times { get '/bench/erubis_single' }
  end

  def test_hammer_builder
    TIMES.times { get '/bench/hammer_builder' }
  end

  def test_tenjin_single
    TIMES.times { get '/bench/tenjin_single' }
  end

  def test_tenjin_partial
    TIMES.times { get '/bench/tenjin_partial' }
  end
end
