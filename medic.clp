(defclass PERSON
    (is-a USER)
	(slot Name (type STRING))
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
)

(defclass EXAMINER
	(is-a PERSON)
	(slot EmployeeID (type STRING))
)

(defclass CHECKPART
    (is-a USER)
	(slot Patient (type INSTANCE) (allowed-classes PATIENT))
	(slot Date (type STRING))
	(slot Cost (type INTEGER))
)

(defclass LABCHECK
    (is-a CHECKPART)
	(slot Examiner (type INSTANCE) (allowed-classes EXAMINER))
	(slot Type (type STRING))
	(slot Result (type STRING))
)

(defclass CHECKUP
    (is-a CHECKPART)
	(slot PrevLabCheck (type INSTANCE) (allowed-classes LABCHECK))
	(slot PrevCheckUp (type INSTANCE) (allowed-classes CHECKUP))
	(slot NextLabCheck (type INSTANCE) (allowed-classes LABCHECK))
	(slot NextCheckUp (type INSTANCE) (allowed-classes CHECKUP))
	(slot Result (type STRING))
	(slot Doctor (type INSTANCE) (allowed-classes DOCTOR))
	(message-handler put-NextCheckUp after)
	(message-handler put-NextLabCheck after)
)

(defclass MEDICALHISTORY
    (is-a USER)
	(slot FirstCheckUp (type INSTANCE) (allowed-classes CHECKUP))
	(message-handler get-TotalCost)
	(message-handler get-BeginDate)
)

(definstances examples
	(doctor1 of DOCTOR
		(Name "dokter1")
		(DateOfBirth "22Dec86")
		(Sex "male")
		(EmployeeID "1000288938102")
		(LicenseID "0008982719200512")
	)
	(patient1 of PATIENT
		(Name "pasien1")
		(DateOfBirth "22Dec86")
		(Sex "male")
		(PatientID "000028134")
		(BloodType "O")
	)
	(examiner1 of EXAMINER
		(Name "dokter1")
		(DateOfBirth "22Dec86")
		(Sex "male")
		(EmployeeID "1000288938102")
	)
	(checkUp1 of CHECKUP 
		(Result "darah tinggi")
		(Cost 100)
		(Date "22Jan2021")
		(Patient [patient1])
		(Doctor [doctor1])
	)
	(medHistory1 of MEDICALHISTORY 
		(FirstCheckUp [travelStep18a])
	)
)
