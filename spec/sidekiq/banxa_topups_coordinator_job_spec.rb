require 'rails_helper'

describe BanxaTopupsCoordinatorJob, type: :job do
  describe '.perform' do
    context 'when there is a reward' do
      it 'uses the reward creation date' do
      end
    end

    context 'with no rewards' do
      it 'uses a default date' do
      end
    end

    context 'without a buy order' do
      it 'does not process the topup' do
      end
    end

    context 'with less than 100 USD topup' do
      it 'does not process the topup' do
      end
    end

    context 'when user topups more than 100 USD' do
      it 'process the topup' do
      end
    end

    context 'enqueues a new search' do
    end
  end
end
