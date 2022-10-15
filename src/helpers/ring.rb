class Ring
  # The structure of the ring varaible is a hex string
  # There's hard design limit of up to 4,096 matches that can be held in this
  # structure
  #
  # The first three chars are an index pointer, telling us the location of the
  # current match
  #
  # The remaining chars are the order sorted, list of match_ids that are
  # currently selected by search parameters.
  # Each match_id is assigned 3 hex chars (hence the hard 4,096 limit)
  #
  # This will be as long as it needs to be. In the worst case in a world cup
  # with 64 matches, with all matches selected, the ring will be:
  #    3 + (64 * 3) = 195 chars long
  def initialize(args)
    check_args(args)
    if args[:ring].nil?
      tmp = build_ring(args)
      @ring = tmp[:ring]
      @index = tmp[:index]
    else
      @ring = args[:ring][3..]
      @index = hex_to_dec(args[:ring][0..2])
    end
    @len = @ring.length / 3
  end

  def to_s
    index = dec_to_hex(@index)
    "#{index}#{@ring}"
  end

  def next_match
    return nil if @index >= (@len - 1)
    next_index = dec_to_hex(@index + 1)
    next_match_id = match_id(@index + 1)
    { match_id: next_match_id,
      ring: "#{next_index}#{@ring}" }
  end

  def prev_match
    return nil if @index <= 0
    prev_index = dec_to_hex(@index - 1)
    prev_match_id = match_id(@index - 1)
    { match_id: prev_match_id,
      ring: "#{prev_index}#{@ring}" }
  end

  private

  # rubocop:disable Metrics/MethodLength, Layout/LineLength
  def check_args(args)
    return unless args[:ring].nil?
    if args[:match_ids].nil?
      raise ArgumentError,
            "Invalid arguments. Must provide a hash with a ring entry or a match_ids entry"
    end
    if !args[:match_ids].is_a?(Array)
      raise ArgumentError,
            "Invalid arguments. match_ids must be an array of selected matches"
    end
    if args[:match_id].nil? &&
       args[:index].nil?
      raise ArgumentError,
            "Invalid arguments. Must provide either a current match_id or an index"
    end
  end
  # rubocop:enable Metrics/MethodLength, Layout/LineLength

  def build_ring(args)
    ring = ''
    index = args[:index] unless args[:index].nil?
    args[:match_ids].each_with_index do |match_id, idx|
      ring << dec_to_hex(match_id)
      index = idx if match_id == args[:match_id]
    end
    { ring: ring,
      index: index }
  end

  def hex_to_dec(hex)
    Integer("0x#{hex}")
  end

  def dec_to_hex(int)
    out = int.to_s(16)
    while out.length < 3
      out = "0#{out}"
    end
    out
  end

  def match_id(index)
    pos_start = index * 3
    pos_end = pos_start + 2
    hex_match_id = @ring[pos_start..pos_end]
    hex_to_dec(hex_match_id)
  end
end
