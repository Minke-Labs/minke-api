require 'rails_helper'

describe MoonpayTopupsCoordinatorJob, type: :job do
  subject { described_class.new }

  describe '.perform' do
    context 'without an incomplete order' do
      let(:top_up) { { status: 'INCOMPLETE' } }
      it 'does not process the topup' do
        allow(Moonpay::Client).to receive(:new)
          .with(50, 0, 1.year.ago.to_date.to_s)
          .and_return(double(search: [top_up]))
        allow(Moonpay::Client).to receive(:new)
          .with(50, 1, 1.year.ago.to_date.to_s)
          .and_return(double(search: []))

        expect(ProcessTopupJob).to_not receive(:perform_async)
        subject.perform
      end
    end

    context 'with less than 100 USD topup' do
      let(:date) { DateTime.now.to_s }
      let(:top_up) do
        { id: 1, status: 'completed', baseCurrencyAmount: 50, usdRate: 1,
          walletAddress: '0x1234', createdAt: date  }
      end

      it 'process the topup' do
        allow(Moonpay::Client).to receive(:new)
          .with(50, 0, 1.year.ago.to_date.to_s)
          .and_return(double(search: [top_up]))
        allow(Moonpay::Client).to receive(:new)
          .with(50, 1, 1.year.ago.to_date.to_s)
          .and_return(double(search: []))

        expect(ProcessTopupJob).to receive(:perform_async)
          .with(1, '0x1234', DateTime.parse(date).to_i, 'moonpay', 50)
        subject.perform
      end
    end

    context 'when user topups more than 100 USD' do
      let(:date) { DateTime.now.to_s }
      let(:top_up) do
        { id: 1, status: 'completed', baseCurrencyAmount: 100, usdRate: 1,
          walletAddress: '0x1234', createdAt: date  }
      end

      it 'process the topup' do
        allow(Moonpay::Client).to receive(:new)
          .with(50, 0, 1.year.ago.to_date.to_s)
          .and_return(double(search: [top_up]))
        allow(Moonpay::Client).to receive(:new)
          .with(50, 1, 1.year.ago.to_date.to_s)
          .and_return(double(search: []))

        expect(ProcessTopupJob).to receive(:perform_async)
          .with(1, '0x1234', DateTime.parse(date).to_i, 'moonpay', 100)
        subject.perform
      end
    end

    context 'enqueues a new search' do
      let(:date) { DateTime.now.to_s }
      let(:top_up) { { status: 'completed', baseCurrencyAmount: 50, usdRate: 1, createdAt: date } }

      it 'check the next page' do
        allow(Moonpay::Client).to receive(:new)
          .with(50, 0, 1.year.ago.to_date.to_s)
          .and_return(double(search: [top_up]))
        allow(Moonpay::Client).to receive(:new)
          .with(50, 1, 1.year.ago.to_date.to_s)
          .and_return(double(search: [top_up]))
        expect(Moonpay::Client).to receive(:new)
          .with(50, 2, 1.year.ago.to_date.to_s)
          .and_return(double(search: []))

        subject.perform
      end
    end
  end
end
