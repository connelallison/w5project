require_relative ("../models/patient.rb")
require_relative ("../models/physio.rb")
require_relative ("../models/condition.rb")
require_relative ("../models/member.rb")
require_relative ("../models/member_lesson.rb")

get '/wellbeing/patients' do
  @patients = Patient.all_ascending_id()
  @show_patients = "show_patients"
  erb(:"patients/index")
end

get '/wellbeing/patients/new' do
  @members = Member.all()
  @patient_member_ids = Patient.all_member_ids()
  erb(:"patients/new")
end

post '/wellbeing/patients/:id/delete' do
  @patient = Patient.find(params[:id].to_i())
  if (@patient == nil); redirect('/wellbeing/patients'); end
  if (@patient!= nil); @patient.delete(); end
  redirect("/wellbeing/patients")
end

get '/wellbeing/patients/:id/edit' do
  @patient = Patient.find(params[:id].to_i())
  erb(:"patients/edit")
end

post '/wellbeing/patients/:id/resolve/:condition_id' do
  @condition = Condition.find(params[:condition_id].to_i())
  @condition.resolve()
  redirect("wellbeing/patients/#{params[:id].to_i()}")
  # redirect("/wellbeing/patients/#{@patient.id}?show_removed=true&physio=#{@physio.course}")
end

post '/wellbeing/patients/:id/add' do
  @patient = Patient.find(params[:patient_id].to_i())
  @physio = Physio.find(params[:physio_id].to_i())
  @patient_physio = @patient.add_physio(@physio)
  @patient_physio.save()
  @physios = Physio.all()
  @show_added = "show_added"
  redirect("/wellbeing/patients/#{@patient.id}?show_added=true&physio=#{@physio.course}")
end

post '/wellbeing/patients/:id' do
  @patient = Patient.find(params[:id].to_i())
  if (params['member'] == "false")
    if (params['membership'] == 'standard')
      @member_id = Member.new('name' => params['patient_name'], 'premium' => false).save()
      @patient.patient_name = params['patient_name']
      @patient.member_id = @member_id
      @patient.update()
    elsif (params['membership'] == 'premium')
      @member_id = Member.new('name' => params['patient_name'], 'premium' => true).save()
      @patient.patient_name = params['patient_name']
      @patient.member_id = @member_id
      @patient.update()
    elsif (params['membership'] == 'no')
      @patient.patient_name = params['patient_name']
      @patient.update()
    end
  elsif (params['member'] == "true")
    if (params['membership'] == 'standard')
      if (@patient.premium == true)
        @member = Member.find(@patient.member_id)
        @member.name = params['patient_name']
        @member.premium = false
        @member.update()
      end
      @patient.patient_name = params['patient_name']
      @patient.update()
    elsif (params['membership'] == 'premium')
      @member_id = Patient.find(params[:id].to_i()).member_id
      if (@patient.premium == false)
        @member = Member.find(@member_id)
        @member.name = params['patient_name']
        @member.premium = true
        @member.update()
      end
      @patient.patient_name = params['patient_name']
      @patient.update()
    elsif (params['membership'] == 'no')
      @member_id = Patient.find(params[:id].to_i()).member_id
      @member = Member.find(@member_id)
      @member.delete()
      @patient = Patient.find(params[:id].to_i())
      @patient.patient_name = params['patient_name']
      @patient.update()
    end
  end
  @patient = Patient.find(params[:id].to_i())
  @conditions = @patient.conditions
  redirect("/wellbeing/patients/#{params[:id].to_i()}")
end



post '/wellbeing/patients' do
  @member_ids = Member.all_ids()
  if (@member_ids.include?(params['member_id'].to_i()))
    @patient = Patient.new(params)
    @patient.save()
  else
    @patient = Patient.new({'patient_name' => params['patient_name']})
    @patient.save()
  end
  redirect("wellbeing/patients")
end

get '/wellbeing/patients/:id' do
  @patient = Patient.find(params[:id].to_i())
  # @show_added = "show_added" if (params[:show_added] == "true")
  # @show_removed = "show_removed" if (params[:show_removed] == "true")
  # @physio = params[:physio] if ((params[:show_added] == "true") || (params[:show_removed] == "true"))
  @conditions = @patient.conditions()
  erb(:"patients/show")
end

get '/wellbeing/conditions/:id' do
  @condition = Condition.find(params[:id])
  @patient_name = @condition.patient.patient_name
  @physio_name = @condition.physio.physio_name
  @return_patient = "return_patient"
  erb(:"conditions/show")
end
