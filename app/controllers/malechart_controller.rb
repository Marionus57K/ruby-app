class MalechartController < ApplicationController
    def index
        @pie = Datasets.prepare_piechart
      end
end
