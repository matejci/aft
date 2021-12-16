# frozen_string_literal: true

require 'rails_helper'

describe BigDecimalAddition, type: :model do
  let(:pool) do
    create(:pool,
           amount: 300,
           estimated_amount: 100,
           processed_amount: 50,
           transferred_amount: 50,
           paid_amount: 99,
           remaining_amount: 1)
  end

  let(:bda) { BigDecimalAddition.new(pool) }

  it 'defines dynamic +=/-= setters for float fields' do
    pool.attributes.each do |attr, val|
      next unless val.is_a? Float

      expect(bda).to respond_to("#{attr} +=")
      expect(bda).to respond_to("#{attr} -=")
    end
  end

  describe '#calc' do
    it 'adds the amount without floating point error' do
      expect(bda.send(:calc, 1.0, 0.001, '+')).to eq(1.001)
      expect(bda.send(:calc, 25.0, 24.999999999, '+')).to eq(49.999999999)
    end

    it 'subtracts the amount without floating point error' do
      expect(bda.send(:calc, 1.0, 0.001, '-')).to eq(0.999)
      expect(bda.send(:calc, 25.0, 24.9999, '-')).to eq(0.0001)
    end
  end

  describe '#attrs +=/-=' do
    it '+=/-= to object' do
      bda.send('processed_amount -=', 5)
      bda.send('transferred_amount +=', 5)
      bda.save!

      pool.reload
      expect(pool.processed_amount).to eq(45)
      expect(pool.transferred_amount).to eq(55)

      bda.send('transferred_amount -=', 12)
      bda.send('paid_amount +=', 12)
      bda.send('processed_amount -=', 0.0000011)
      bda.send('remaining_amount +=', 0.0000011)
      bda.save!

      pool.reload
      expect(pool.transferred_amount).to eq(43)
      expect(pool.paid_amount).to eq(111)
      expect(pool.processed_amount).to eq(44.9999989)
      expect(pool.remaining_amount).to eq(1.0000011)
    end
  end
end
