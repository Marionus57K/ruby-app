class DatasetController < ApplicationController

  def index
    @stuff = Datasets.retrieve_dataset
  end
end
