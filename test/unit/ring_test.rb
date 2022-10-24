require_relative '../helpers/test_helpers'
require "#{App.settings.src}/helpers/ring"

class CMSTest < Minitest::Test

  def test_create_with_ring
    ring = Ring.new({ ring: 'eJwzMDA0ACEjAwNjAA7IAkg=' })
    assert_equal 'eJwzMDA0ACEjAwNjAA7IAkg=', ring.to_s

    out = ring.next_match
    assert_equal 3, out[:match_id]
    assert_equal 'eJwzMDAyMDA0AJHGAA7SAkk=', out[:ring]

    out = ring.prev_match
    assert_equal 1, out[:match_id]
    assert_equal 'eJwzMAACQwMDIwMDYwAOvgJH', out[:ring]
  end

  def test_create_with_matchids_index
    ring = Ring.new({ match_ids: [1, 2, 3], index: 1 })
    assert_equal 'eJwzMDA0ACEjAwNjAA7IAkg=', ring.to_s

    out = ring.next_match
    assert_equal 3, out[:match_id]
    assert_equal 'eJwzMDAyMDA0AJHGAA7SAkk=', out[:ring]

    out = ring.prev_match
    assert_equal 1, out[:match_id]
    assert_equal 'eJwzMAACQwMDIwMDYwAOvgJH', out[:ring]
  end

  def test_create_with_matchids_matchid
    ring = Ring.new({ match_ids: [1, 2, 3], match_id: 2 })
    assert_equal  'eJwzMDA0ACEjAwNjAA7IAkg=', ring.to_s

    out = ring.next_match
    assert_equal 3, out[:match_id]
    assert_equal 'eJwzMDAyMDA0AJHGAA7SAkk=', out[:ring]

    out = ring.prev_match
    assert_equal 1, out[:match_id]
    assert_equal 'eJwzMAACQwMDIwMDYwAOvgJH', out[:ring]
  end

  def test_create_with_matchids_no_matchid_no_index
    assert_raises(ArgumentError) { Ring.new({ match_ids: [1, 2, 3] }) }
  end

  def test_create_with_matchids_str
    assert_raises(ArgumentError) { Ring.new({ match_ids: '1, 2, 3', match_id: 2 }) }
  end

  def test_create_no_matchids_no_ring
    assert_raises(ArgumentError) { Ring.new({ match_id: 2 }) }
  end

  def test_create_with_matchids_out_of_order
    ring = Ring.new({ match_ids: [1, 3, 2], match_id: 3 })
    assert_equal 'eJwzMDA0ACFjAwMjAA7LAkg=', ring.to_s

    out = ring.next_match
    assert_equal 2, out[:match_id]
    assert_equal 'eJwzMDAyMDA0MDA2MDACAA7VAkk=', out[:ring]

    out = ring.prev_match
    assert_equal 1, out[:match_id]
    assert_equal 'eJwzMAACQwMDYwMDIwAOwQJH', out[:ring]
  end

  def test_create_with_matchids_into_hex
    ring = Ring.new({ match_ids: [11, 23, 270], match_id: 23 })
    assert_equal 'eJwzMDA0MEgyMDQ3NEgFABBtArI=', ring.to_s

    out = ring.next_match
    assert_equal 270, out[:match_id]
    assert_equal 'eJwzMDAyMEgyMDQ3NEgFABB3ArM=', out[:ring]

    out = ring.prev_match
    assert_equal 11, out[:match_id]
    assert_equal 'eJwzMACCJANDc0ODVAAQYwKx', out[:ring]
  end

  def test_create_with_index_into_hex
    ring = Ring.new({ match_ids: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16], match_id: 14 })
    assert_equal 'eJwVyskBwBAAALCV4qjWOBT7j4C8wyAQSWQeCi8flUbnd9tknbsBFcsLKA==', ring.to_s

    out = ring.next_match
    assert_equal 15, out[:match_id]
    assert_equal 'eJwVyskBwBAAALCV4qjWOBT7j4C8wyQQSWQeCi8flUbnZ7hznbsBFfwLKQ==', out[:ring]

    out = ring.prev_match
    assert_equal 13, out[:match_id]
    assert_equal 'eJwVyskBwBAAALCV4qjWOBT7j4C8w08gksg8FF4-Ko3unsFknbsBFZoLJw==', out[:ring]
  end

  def test_create_at_start
    ring = Ring.new({ match_ids: [1, 2, 3], match_id: 1 })
    assert_equal 'eJwzMAACQwMDIwMDYwAOvgJH', ring.to_s

    out = ring.next_match
    assert_equal 2, out[:match_id]
    assert_equal 'eJwzMDA0ACEjAwNjAA7IAkg=', out[:ring]

    assert_nil(ring.prev_match)
  end

  def test_create_at_end
    ring = Ring.new({ match_ids: [1, 2, 3], match_id: 3 })
    assert_equal 'eJwzMDAyMDA0AJHGAA7SAkk=', ring.to_s

    assert_nil(ring.next_match)

    out = ring.prev_match
    assert_equal 2, out[:match_id]
    assert_equal 'eJwzMDA0ACEjAwNjAA7IAkg=', out[:ring]
  end
end