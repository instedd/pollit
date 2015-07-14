class AnswersListing < BaseAnswersListing
  column respondent: :phone, title: _('Respondent') do |item|
    item.respondent.unprefixed_phone
  end

  column question: :title, title: _('Question')
  column :response, title: _('Answer')

  column :created_at, title: _('Date') do |item, value|
    value.strftime("%Y-%m-%d %H:%M:%S")
  end

  export :csv, :xls
  paginates_per 5
end






