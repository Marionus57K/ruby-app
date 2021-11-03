require 'uri'
require 'net/http'

class Datasets < ApplicationRecord

  URL       = "https://ghoapi.azureedge.net/api"
  INDICATOR = "/SDGSUICIDE"

#   def initialize(data)
#     @country = data[:country],
#     @year = data[:year],
#     @sex = data[:sex],
#     @age_group = data[:age_group],
#     @value = data[:value],
#     @date = data[:date]
#   end


  def self.get_dataset_response
    uri = URI(URL + INDICATOR)
    response = Net::HTTP.get_response(uri)

    response
  end

  def self.get_dataset
    response = get_dataset_response
    parsed_response = JSON.parse(response.body)

    #This should be hash
    parsed_response
  end

  def self.format_dataset
    parsed_response = get_dataset['value']
    response_hash = parsed_response.map do | row |
      {
        country: row['SpatialDim'],
        year: row['TimeDim'],
        sex: row['Dim1'],
        age_group: row['Dim2'],
        value: row['Value'],
        date: row['Date']
      }
    end

    response_hash
  end

  def self.save_dataset
    parsed_response = get_dataset['value']
    response_hash = parsed_response.map do | row |
        Dataset.create(
        country: row['SpatialDim'],
        year: row['TimeDim'],
        sex: row['Dim1'],
        age_group: row['Dim2'],
        value: row['Value'],
        date: row['Date']
        )
    end
  end

  def self.retrieve_dataset
    #Optimize this if possible? Perhaps Hash?
    @dataset = Datasets.pluck(
      :id,
      :country,
      :year,
      :sex,
      :age_group,
      :value,
      :date
    )
  end

  def index
     
  end
end
