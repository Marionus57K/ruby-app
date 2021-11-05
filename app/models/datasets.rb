require 'uri'
require 'net/http'
require 'countries/global'
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
    #Why are we chaining functions like this? Refactor
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

  #Unnecessary calls - move to singleton
  def self.save_dataset
    parsed_response = get_dataset['value']
    parsed_response.map do | row |

      # Function <- move
      country_code = row['SpatialDim'].downcase
      country_name = ISO3166::Country.find_country_by_alpha3(country_code)

      @country_name_array << country_name


      if row['Dim1'] = "MLE"
        sex = "Male"
      elsif row['Dim1'] = "FMLE"
        sex = "Female"
      else 
        sex = "Both"
      end

      #@TODO: Check why chomp doesnt work (add second param??)
      if !row['Dim2'].nil?
        age_group = row['Dim2'].chomp('YEARS')
      end
        #This can be refactored
        Datasets.create(
        country: country_name,
        year: row['TimeDim'],
        sex: sex,
        age_group: age_group,
        value: row['Value'],
        date: row['Date']
        )
    end
  end

  def self.retrieve_dataset
    country_name_array = []

    # Optimize this if possible? Perhaps Hash?
    @dataset = Datasets.pluck(
      :country,
      :year,
      :sex,
      :age_group,
      :value,
      :date
    )

    @dataset.map do | row |

      if !row[0].nil?
        country_code = row[0].downcase
      end

      country_name = ISO3166::Country.find_country_by_alpha3(country_code)


      if !country_name_array.include?(country_name.to_s) && !country_name.to_s.empty?
        country_name_array << country_name.to_s
      end
    end

    country_name_array
  end

  def self.prepare_average

    country_name_array = retrieve_dataset

    country_average_data = []
    
    country_name_array.each do |n|
      values = []
      if !Datasets.where(country: n).pluck(:value).kind_of?(Array)
        cname = Datasets.where(country: n).pluck(
          :value
        )

        #Check for gem nomenclature
        if cname.eq('Russian Federation')
          cname = "Russia"
          values << cname
      else
        values << Datasets.where(country: n).pluck(
          :value
        )
      end
      else
        subarr = Datasets.where(country: n).pluck(:value)

        subarr.each do |f|
          values << f.gsub(/\s.*/, '').to_f
        end
      end
      tmp_country_avg_holder = [
        n,
        (values.inject{ |sum, el| sum + el }.to_f / values.size).round(2).to_s
      ]

      country_average_data << tmp_country_avg_holder
    end

    logger.debug(country_average_data)

    country_average_data
  end

  def self.prepare_piechart

    malearr = []
    femalearr = []

    @dataset = Datasets.pluck(
      :country,
      :year,
      :sex,
      :age_group,
      :value,
      :date
    )

    @dataset.map do | row |
      logger.debug(row[2])
      if (row[2] == 'Male')
        malearr << row[4].gsub(/\s.*/, '').to_f
      elsif (row[2] == 'FMLE')
        femalearr << row[4].gsub(/\s.*/, '').to_f
      end
    end

    malearrperc = get_pie_average(malearr)
    femalearrperc = get_pie_average(femalearr)

    avs = [malearrperc, femalearrperc]
    avs
  end

  private 

  def self.get_pie_average(arr)
    (arr.inject{ |sum, el| sum + el }.to_f / arr.size).round(2).to_s
  end

end
