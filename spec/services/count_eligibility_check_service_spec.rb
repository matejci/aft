# frozen_string_literal: true

require 'rails_helper'

describe CountEligibilityCheckService do
  let(:day) { 2.days.ago.beginning_of_day }

  it 'returns false for flagged view tracking' do
    result = service_call(flagged: true)
    expect(result[:eligible]).to eq(false)
    expect(result[:current_counts]).to eq([])
  end

  it 'returns true for empty current counts' do
    result = service_call
    expect(result[:eligible]).to eq(true)
    expect(result[:current_counts].length).to eq(1)
  end

  it 'returns true when current counts less than 2' do
    result = service_call(current_counts: [day + 1.minute])
    expect(result[:eligible]).to eq(true)
    expect(result[:current_counts].length).to eq(2)
  end

  it 'returns true when current 2 counts are from same hour and current one is from next hour' do
    result = service_call(current_counts: [day + 3.minutes, day + 5.minutes], started_at: day + 2.hours)
    expect(result[:eligible]).to eq(true)
  end

  it 'returns false when current 2 counts are from same hour and current one is from same hour' do
    result = service_call(current_counts: [day + 3.minutes, day + 5.minutes], started_at: day + 7.minutes)
    expect(result[:eligible]).to eq(false)
  end

  it 'returns false when current 2 counts are from different hour' do
    result = service_call(current_counts: [day + 3.minutes, day + 5.hours])
    expect(result[:eligible]).to eq(false)
  end

  it 'returns true when current counts more than 2 (maximum) but from past day' do
    started_at = day + 2.days + 2.minutes
    result = service_call(current_counts: [day + 3.minutes, day + 5.minutes, day - 10.minutes], started_at: started_at)
    expect(result[:eligible]).to eq(true)
    expect(result[:current_counts]).to eq([started_at])
  end

  it 'returns false when current counts more than 2 (maximum)' do
    result = service_call(current_counts: [day + 3.minutes, day + 5.minutes, day - 10.minutes])
    expect(result[:eligible]).to eq(false)
  end

  def service_call(flagged: false, current_counts: [], started_at: day + 1.day - 1.minute)
    CountEligibilityCheckService.new(
      flagged: flagged, current_counts: current_counts, started_at: started_at
    ).call
  end
end
