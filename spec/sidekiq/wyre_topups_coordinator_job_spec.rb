require 'rails_helper'

describe WyreTopupsCoordinatorJob, type: :job do
  subject { described_class.new }

  describe '.perform' do
    context 'without an incomplete order' do
      let(:top_up) { { status: 'INCOMPLETE' } }
      it 'does not process the topup' do
        allow(Wyre::Client).to receive(:new)
          .with(200, 0)
          .and_return(double(search: [top_up]))
        allow(Wyre::Client).to receive(:new)
          .with(200, 1)
          .and_return(double(search: []))

        expect(ProcessTopupJob).to_not receive(:perform_async)
        subject.perform
      end
    end

    context 'with less than 100 USD topup' do
      let(:date) { DateTime.now.to_i }
      let(:top_up) do
        { id: 1, status: 'COMPLETE', usd_purchase_amount: 50,
          dest: 'matic:0x1234', created_at: date  }
      end

      it 'process the topup' do
        allow(Wyre::Client).to receive(:new)
          .with(200, 0)
          .and_return(double(search: [top_up]))
        allow(Wyre::Client).to receive(:new)
          .with(200, 1)
          .and_return(double(search: []))

        expect(ProcessTopupJob).to receive(:perform_async)
          .with(1, 'matic:0x1234', date / 1000, 'wyre', 50)
        subject.perform
      end
    end

    context 'when user topups more than 100 USD' do
      let(:date) { DateTime.now.to_i }
      let(:top_up) do
        { id: 1, status: 'COMPLETE', usd_purchase_amount: 100,
          dest: 'matic:0x1234', created_at: date  }
      end

      it 'process the topup' do
        allow(Wyre::Client).to receive(:new)
          .with(200, 0)
          .and_return(double(search: [top_up]))
        allow(Wyre::Client).to receive(:new)
          .with(200, 1)
          .and_return(double(search: []))

        expect(ProcessTopupJob).to receive(:perform_async)
          .with(1, 'matic:0x1234', date / 1000, 'wyre', 100)
        subject.perform
      end
    end

    context 'enqueues a new search' do
      let(:date) { DateTime.now.to_i }
      let(:top_up) { { status: 'COMPLETE', coin_code: 'USDC', usd_purchase_amount: 50, created_at: date } }

      it 'check the next page' do
        allow(Wyre::Client).to receive(:new)
          .with(200, 0)
          .and_return(double(search: [top_up]))
        allow(Wyre::Client).to receive(:new)
          .with(200, 1)
          .and_return(double(search: [top_up]))
        expect(Wyre::Client).to receive(:new)
          .with(200, 2)
          .and_return(double(search: []))

        subject.perform
      end
    end
  end
end
