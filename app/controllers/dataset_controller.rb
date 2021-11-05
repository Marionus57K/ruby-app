class DatasetController < ApplicationController

  def index
    @dataset = Datasets.prepare_average
  end
end
