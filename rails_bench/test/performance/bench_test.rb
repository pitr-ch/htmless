require 'test_helper'
require 'rails/performance_test_help'

# Profiling results for each test method are written to tmp/performance.
class BenchTest < ActionDispatch::PerformanceTest
  TIMES = 100
  def test_erubis_partials
    TIMES.times { get '/bench/erubis_partials' }
  end

  def test_erubis_single
    TIMES.times { get '/bench/erubis_single' }
  end

  def test_hammer_builder
    TIMES.times { get '/bench/hammer_builder' }
  end
end
