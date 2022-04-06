(defclass PERSON
    (is-a USER)
	(slot Name (type STRING) (visibility public))
	(slot DateOfBirth (type STRING))
	(slot Sex (allowed-values male female))
)

(defclass DOCTOR
	(is-a PERSON)
	(slot EmployeeID (type STRING))
	(slot LicenseID (type STRING))
)

(defclass PATIENT
	(is-a PERSON)
	(slot PatientID (type STRING))
	(slot BloodType (type STRING))
	(slot MedicalHistory (type INSTANCE) (allowed-classes MEDICALHISTORY))
	(message-handler get-BeginTreatmentDate)
	(message-handler get-MedicalHistoryList)
	(message-handler get-TotalCost)
)

(defmessage-handler PATIENT get-BeginTreatmentDate ()
	(bind ?firstCheckUp (send ?self:MedicalHistory get-FirstCheckUp))
	(bind ?firstCheckDate (send ?firstCheckUp get-Date))
	(printout t "First checkup date: " ?firstCheckDate crlf)
)


(defmessage-handler PATIENT get-MedicalHistoryList ()
	(bind ?currentStep (send ?self:MedicalHistory get-FirstCheckUp))
	(bind ?currentDate (send ?currentStep get-Date))
	(bind ?curretDoctor (send ?currentStep get-DoctorName))
	(printout t "Checkup " ?currentDate " (" ?curretDoctor "): "  (send ?currentStep get-Result) crlf)
	(while TRUE do
		(bind ?nextLabCheck (send ?currentStep get-NextLabCheck))
		(if (neq ?nextLabCheck [nil]) then
				(bind ?labDate (send ?nextLabCheck get-Date))
				(bind ?labExaminer (send ?nextLabCheck get-ExaminerName))
				(printout t "Labcheck " ?labDate " (" ?labExaminer "): "  (send ?nextLabCheck get-Result) crlf)
		)
		(bind ?nextCheckUp (send ?currentStep get-NextCheckUp))
		(if (neq ?nextCheckUp [nil]) then
				(bind ?currentStep ?nextCheckUp)
				(bind ?currentDate (send ?currentStep get-Date))
				(bind ?curretDoctor (send ?currentStep get-DoctorName))
				(printout t "Checkup " ?currentDate " (" ?curretDoctor "): "  (send ?currentStep get-Result) crlf)
		)
		(if (eq (send ?currentStep get-NextCheckUp) [nil]) then (break))
	)
)

(defmessage-handler PATIENT get-TotalCost ()
	(bind ?currentStep (send ?self:MedicalHistory get-FirstCheckUp))
	(bind ?totalCost (send ?currentStep get-Cost))
	(while TRUE do
		(bind ?nextLabCheck (send ?currentStep get-NextLabCheck))
		(if (neq ?nextLabCheck [nil]) then
				(bind ?currentLabCost (send ?nextLabCheck get-Cost))
				(bind ?totalCost (+ ?totalCost ?currentLabCost))
		)
		(bind ?nextCheckUp (send ?currentStep get-NextCheckUp))
		(if (neq ?nextCheckUp [nil]) then
				(bind ?currentStep ?nextCheckUp)
				(bind ?currentCheckUpCost (send ?nextCheckUp get-Cost))
				(bind ?totalCost (+ ?totalCost ?currentCheckUpCost))
		)
		(if (eq (send ?currentStep get-NextCheckUp) [nil]) then (break))
	)
	(printout t "Total Cost: " ?totalCost crlf)
)

(defclass EXAMINER
	(is-a PERSON)
	(slot EmployeeID (type STRING))
)

(defclass CHECKPART
    (is-a USER)
	(slot Date (type STRING) (visibility public))
	(slot Cost (type INTEGER))
	(message-handler get-Patient)
)

(defclass LABCHECK
    (is-a CHECKPART)
	(slot Examiner (type INSTANCE) (allowed-classes EXAMINER))
	(slot Type (type STRING))
	(slot Result (type STRING))
	(message-handler get-ExaminerName)
)

(defmessage-handler LABCHECK get-ExaminerName ()
	(send ?self:Examiner get-Name)
)

(defclass CHECKUP
    (is-a CHECKPART)
	(slot PrevLabCheck (type INSTANCE) (allowed-classes LABCHECK) (visibility public) (create-accessor read-write))
	(slot PrevCheckUp (type INSTANCE) (allowed-classes CHECKUP) (visibility public) (create-accessor read-write))
	(slot NextLabCheck (type INSTANCE) (allowed-classes LABCHECK) (visibility public) (create-accessor read-write))
	(slot NextCheckUp (type INSTANCE) (allowed-classes CHECKUP) (visibility public) (create-accessor read-write))
	(slot Result (type STRING))
	(slot Doctor (type INSTANCE) (allowed-classes DOCTOR))
	(message-handler put-NextCheckUp after)
	(message-handler put-NextLabCheck after)
	(message-handler put-prevCheckUp after)
	(message-handler get-DoctorName)
)

(defmessage-handler CHECKUP get-DoctorName ()
	(send ?self:Doctor get-Name)
)

(defmessage-handler CHECKUP put-NextCheckUp after (?value)
	;; if in a current CHECKUP, a NextCheckUp is defined
	;; define the NextCheckUp.PrevCheckUp as the current CHECKUP
	;; to make a linked list
	(if (eq (send ?value get-PrevCheckUp) [nil])
		then (send ?value put-PrevCheckUp ?self)
	)
)

(defmessage-handler CHECKUP put-PrevCheckUp after (?value)
	;; if in a current CHECKUP, a prevCheckUp is defined
	;; define the prevCheckUp.NextCheckUp as the current CHECKUP
	;; to make a linked list
	(if (eq (send ?value get-NextCheckUp) [nil])
		then (send ?value put-NextCheckUp ?self)
	)
)

(defclass MEDICALHISTORY
    (is-a USER)
	(slot FirstCheckUp (type INSTANCE) (allowed-classes CHECKUP))
	(message-handler get-Patient)
)

(definstances examples
	(doctor1 of DOCTOR
		(Name "dokter1")
		(DateOfBirth "22Dec86")
		(Sex "male")
		(EmployeeID "1000288938102")
		(LicenseID "0008982719200512")
	)
	(examiner1 of EXAMINER
		(Name "examiner1")
		(DateOfBirth "22Dec86")
		(Sex "male")
		(EmployeeID "1000288938102")
	)
	(labCheck1 of LABCHECK 
		(Date "25Jan2021")
		(Cost 200)
		(Type "gula darah")
		(Result "tinggi")
		(Examiner [examiner1])
	)
	(checkUp1 of CHECKUP 
		(Result "gejala darah tinggi")
		(Cost 100)
		(Date "22Jan2021")
		(Doctor [doctor1])
		(NextLabCheck [labCheck1])
	)
	(checkUp2 of CHECKUP 
		(Result "gejala darah sudah normal")
		(Cost 150)
		(Date "28Jan2021")
		(Doctor [doctor1])
		(PrevCheckUp [checkUp1])
		(PrevLabCheck [labCheck1])
		(NextLabCheck [labCheck2])
	)
	(medHistory1 of MEDICALHISTORY 
		(FirstCheckUp [checkUp1])
	)
	(patient1 of PATIENT
		(Name "pasien1")
		(DateOfBirth "22Dec86")
		(Sex "male")
		(PatientID "000028134")
		(BloodType "O")
		(MedicalHistory [medHistory1])
	)
)
