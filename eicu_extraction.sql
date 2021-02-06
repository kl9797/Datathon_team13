
SELECT pt.patientunitstayid, pt.age, pt.apacheadmissiondx, pt.hospitalID, pt.unitType,
       CASE WHEN pt.gender = 'Male' THEN 1
            WHEN pt.gender = 'Female' THEN 2
            ELSE NULL END AS gender,
       CASE WHEN pt.hospitaldischargestatus = 'Alive' THEN 0
            WHEN pt.hospitaldischargestatus = 'Expired' THEN 1
            ELSE NULL END AS hosp_mortality,
       CASE WHEN pt.apacheAdmissionDx in ('Bleeding, GI from esophageal varices/portal hypertension', 'Bleeding, GI-location unknown', 'Bleeding, lower GI', 'Bleeding, upper GI', 'Bleeding-lower GI, surgery for', 'Bleeding-other GI, surgery for', 'Bleeding-upper GI, surgery for', 'Bleeding-variceal, surgery for (excluding vascular shunting-see surgery for portosystemic shunt)', 'GI perforation/rupture', 'GI perforation/rupture, surgery for', 'Hemorrhage, intra/retroperitoneal', 'Ulcer disease, peptic') THEN 1
            ELSE NULL END AS hosp_include,    
       ROUND(pt.unitdischargeoffset/60) AS icu_los_hours
FROM `physionet-data.eicu_crd.patient` pt
ORDER BY pt.patientunitstayid;

SELECT pt.*
FROM `alien-works-293116.Datathon_AMI.eicu_GI` pt
WHERE pt.hosp_include = 1;

------------------------------lab_test--------------------------------------------
    SELECT
    pvt.patientunitstayid
    , max(CASE WHEN labname = 'Hct' THEN labresult ELSE null END) as HEMATOCRIT_max
    , min(CASE WHEN labname = 'Hct' THEN labresult ELSE null END) as HEMATOCRIT_min
    , min(CASE WHEN labname = 'Hgb' THEN labresult ELSE null END) as HEMOGLOBIN_min
    , max(CASE WHEN labname = 'Hgb' THEN labresult ELSE null END) as HEMOGLOBIN_max
    , min(CASE WHEN labname = 'platelets x 1000' THEN labresult ELSE null END) as PLATELET_min
    , max(CASE WHEN labname = 'platelets x 1000' THEN labresult ELSE null END) as PLATELET_max
    , min(CASE WHEN labname = 'WBC x 1000' THEN labresult ELSE null end) as WBC_min
    , max(CASE WHEN labname = 'WBC x 1000' THEN labresult ELSE null end) as WBC_max
    , min(CASE WHEN labname = 'anion gap' THEN labresult ELSE null END) as ANIONGAP_min
    , max(CASE WHEN labname = 'anion gap' THEN labresult ELSE null END) as ANIONGAP_max
    , min(CASE WHEN labname = 'bicarbonate' OR labname ='HCO3' THEN labresult ELSE null END) as BICARBONATE_min
    , max(CASE WHEN labname = 'bicarbonate' OR labname ='HCO3' THEN labresult ELSE null END) as BICARBONATE_max
    , min(CASE WHEN labname = 'BUN' THEN labresult ELSE null end) as BUN_min
    , max(CASE WHEN labname = 'BUN' THEN labresult ELSE null end) as BUN_max
    , min(CASE WHEN labname = 'calcium' THEN labresult ELSE null end) as CALCIUM_min
    , max(CASE WHEN labname = 'calcium' THEN labresult ELSE null end) as CALCIUM_max
    , min(CASE WHEN labname = 'chloride' THEN labresult ELSE null END) as CHLORIDE_min
    , max(CASE WHEN labname = 'chloride' THEN labresult ELSE null END) as CHLORIDE_max
    , min(CASE WHEN labname = 'creatinine' THEN labresult ELSE null END) as CREATININE_min
    , max(CASE WHEN labname = 'creatinine' THEN labresult ELSE null END) as CREATININE_max
    , min(CASE WHEN labname = 'sodium' THEN labresult ELSE null END) as SODIUM_min
    , max(CASE WHEN labname = 'sodium' THEN labresult ELSE null end) as SODIUM_max
    , min(CASE WHEN labname = 'potassium' THEN labresult ELSE null END) as POTASSIUM_min
    , max(CASE WHEN labname = 'potassium' THEN labresult ELSE null END) as POTASSIUM_max
    , min(CASE WHEN labname = 'PT - INR' THEN labresult ELSE null END) as INR_min
    , max(CASE WHEN labname = 'PT - INR' THEN labresult ELSE null END) as INR_max
    , min(CASE WHEN labname = 'PT' THEN labresult ELSE null END) as PT_min
    , max(CASE WHEN labname = 'PT' THEN labresult ELSE null END) as PT_max
    , min(CASE WHEN labname = 'PTT' THEN labresult ELSE null END) as PTT_min
    , max(CASE WHEN labname = 'PTT' THEN labresult ELSE null END) as PTT_max
    , min(CASE WHEN labname = 'glucose' THEN labresult ELSE null END) as GLUCOSE_min
    , max(CASE WHEN labname = 'glucose' THEN labresult ELSE null END) as GLUCOSE_max
    , avg(CASE WHEN labname = 'glucose' THEN labresult ELSE null END) as GLUCOSE_mean
    , min(CASE WHEN labname = 'lactate' THEN labresult ELSE null END) as LACTATE_min
    , max(CASE WHEN labname = 'lactate' THEN labresult ELSE null END) as LACTATE_max

    FROM
    ( -- begin query that extracts the data
    SELECT p.patientunitstayid, le.labname

    -- add in some sanity checks on the values; same checks from original MIMIC version
    -- the where clause below requires all labresult to be > 0, so these are only upper limit checks
    , CASE
        WHEN labname = 'albumin' and le.labresult >    10 THEN null -- g/dL 'ALBUMIN'
        WHEN labname = 'anion gap' and le.labresult > 10000 THEN null -- mEq/L 'ANION GAP'
        WHEN labname = 'bicarbonate' and le.labresult > 10000 THEN null -- mEq/L 'BICARBONATE'
        WHEN labname = 'HCO3' and le.labresult > 10000 THEN null -- mEq/L 'BICARBONATE'
        WHEN labname = 'bilirubin' and le.labresult >   150 THEN null -- mg/dL 'BILIRUBIN'
        WHEN labname = 'chloride' and le.labresult > 10000 THEN null -- mEq/L 'CHLORIDE'
        WHEN labname = 'creatinine' and le.labresult >   150 THEN null -- mg/dL 'CREATININE'
        WHEN labname = 'glucose' and le.labresult > 10000 THEN null -- mg/dL 'GLUCOSE'
        WHEN labname = 'Hct' and le.labresult >   100 THEN null -- % 'HEMATOCRIT'
        WHEN labname = 'Hgb' and le.labresult >    50 THEN null -- g/dL 'HEMOGLOBIN'
        WHEN labname = 'lactate' and le.labresult >    50 THEN null -- mmol/L 'LACTATE'
        WHEN labname = 'platelets x 1000' and le.labresult > 10000 THEN null -- K/uL 'PLATELET'
        WHEN labname = 'potassium' and le.labresult >    30 THEN null -- mEq/L 'POTASSIUM'
        WHEN labname = 'PTT' and le.labresult >   150 THEN null -- sec 'PTT'
        WHEN labname = 'PT - INR' and le.labresult >    50 THEN null -- 'INR'
        WHEN labname = 'PT' and le.labresult >   150 THEN null -- sec 'PT'
        WHEN labname = 'sodium' and le.labresult >   200 THEN null -- mEq/L == mmol/L 'SODIUM'
        WHEN labname = 'BUN' and le.labresult >   300 THEN null -- 'BUN'
        WHEN labname = 'WBC x 1000' and le.labresult >  1000 THEN null -- 'WBC'
    ELSE le.labresult
    END AS labresult

    FROM `physionet-data.eicu_crd.patient` p

    LEFT JOIN `physionet-data.eicu_crd.lab` le
        ON p.patientunitstayid = le.patientunitstayid
        AND le.labresultoffset <= 1440
        AND le.labname in
        (
            'anion gap',
            'albumin',
            '-bands',
            'bicarbonate',
            'HCO3',
            'total bilirubin',
            'creatinine',
            'calcium',
            'chloride',
            'glucose',
            'Hct',
            'Hgb',
            'lactate',
            'platelets x 1000',
            'potassium',
            'PTT',
            'PT - INR',
            'PT',
            'sodium',
            'BUN',
            'WBC x 1000'
        )
        AND labresult IS NOT null AND labresult > 0 -- lab values cannot be 0 and cannot be negative
    ) pvt
    GROUP BY pvt.patientunitstayid
    
-----------------------------------vital-sign----------------------------------------------------------

    SELECT 
    patientunitstayid,
    MIN(heartrate) as heart_rate_min,
    MAX(heartrate) as heart_rate_max,
    AVG(heartrate) as heart_rate_mean,
    MIN(systemicSystolic) as sbp_min,
    MAX(systemicSystolic) as sbp_max,
    AVG(systemicSystolic) as sbp_mean,
    MIN(systemicDiastolic) as dbp_min,
    MAX(systemicDiastolic) as dbp_max,
    AVG(systemicDiastolic) as dbp_mean,
    MIN(systemicMean) as mbp_min,
    MAX(systemicMean) as mbp_max,
    AVG(systemicMean) as mbp_mean,
    MIN(respiration) as resp_rate_min,
    MAX(respiration) as resp_rate_max,
    AVG(respiration) as resp_rate_mean,
    MIN(temperature) as temperature_min,
    MAX(temperature) as temperature_max,
    AVG(temperature) as temperature_mean,
    MIN(saO2) as spo2_min,
    MAX(saO2) as spo2_max,
    AVG(saO2) as spo2_mean
    FROM (
        SELECT
        patientunitstayid,
        CASE WHEN heartrate BETWEEN 20 AND 300 THEN heartrate ELSE NULL END AS heartrate,
        CASE WHEN systemicSystolic BETWEEN 40 AND 300 THEN systemicSystolic ELSE NULL END AS systemicSystolic,
        CASE WHEN systemicDiastolic BETWEEN 20 AND 200 THEN systemicDiastolic ELSE NULL END AS systemicDiastolic,
        CASE WHEN systemicMean BETWEEN 32 AND 267 THEN systemicMean ELSE NULL END AS systemicMean,
        CASE WHEN respiration BETWEEN 4 AND 50 THEN respiration ELSE NULL END AS respiration,
        CASE WHEN temperature BETWEEN 32 AND 43 THEN temperature ELSE NULL END AS temperature,
        CASE WHEN saO2 BETWEEN 50 AND 100 THEN saO2 ELSE NULL END AS saO2,
        FROM `physionet-data.eicu_crd.vitalperiodic`
        WHERE observationOffset <= 1440
        UNION ALL
        SELECT 
        patientunitstayid,
        NULL AS heartrate,
        CASE WHEN nonInvasiveSystolic BETWEEN 40 AND 300 THEN nonInvasiveSystolic  ELSE NULL END AS systemicSystolic,
        CASE WHEN nonInvasiveDiastolic BETWEEN 20 AND 200 THEN nonInvasiveDiastolic ELSE NULL END AS systemicDiastolic,
        CASE WHEN nonInvasiveMean BETWEEN 32 AND 267 THEN nonInvasiveMean ELSE NULL END AS systemicMean,
        NULL AS respiration,
        NULL AS temperature,
        NULL AS saO2,
        FROM `physionet-data.eicu_crd.vitalaperiodic`
        WHERE observationOffset <= 1440
    )
    GROUP BY patientunitstayid
 
----------------------------------------demographics and treatment----------------------------------------------

with patient as (
    SELECT 
    patientunitstayid, 
    age,
    gender,
    SAFE_DIVIDE(admissionWeight,POW(admissionHeight/100,2)) AS BMI,
    hospitalDischargeStatus AS mortality,
    unitDischargeOffset/60 AS icu_los_hours
    FROM `physionet-data.eicu_crd.patient`
), diagnosis AS (
    SELECT 
    patientunitstayid,
    MAX(CASE WHEN LOWER(diagnosisstring) LIKE '%acute coronary syndrome%' OR LOWER(diagnosisstring) LIKE '%coronary artery disease%' THEN 1 ELSE 0 END) AS ihd,
    MAX(CASE WHEN LOWER(diagnosisstring) LIKE '%diabetes mellitus%' THEN 1 ELSE 0 END) as diabetes,
    MAX(CASE WHEN LOWER(diagnosisstring) LIKE '%hypertension%' AND LOWER(diagnosisstring) NOT LIKE '%pulmonary hypertension%' AND LOWER(diagnosisstring) NOT LIKE '%reflex hypertension%' THEN 1 ELSE 0 END) as hypertension,
    MAX(CASE WHEN LOWER(diagnosisstring) LIKE '%chronic kidney disease%' THEN 1 ELSE 0 END) AS ckd,
    MAX(CASE WHEN LOWER(diagnosisstring) LIKE '%cancer%' OR LOWER(diagnosisstring) LIKE '%malignancy%' THEN 1 ELSE 0 END) AS malignancy,
    FROM `physionet-data.eicu_crd.diagnosis`
    GROUP BY patientunitstayid
), sofa AS (
    with pivoted_sofa AS (
        with all_days as (
            select
            patientunitstayid
            , 0 as endoffset
            , unitdischargeoffset
            , GENERATE_ARRAY(1, CAST(ceil(unitdischargeoffset/1440) AS INT64)) as day
            from `physionet-data.eicu_crd.patient`
        ), vasopressor AS (
    select
    patientunitstayid, 
    max(case when treatmentstring in
    (
        'toxicology|drug overdose|vasopressors|vasopressin' --                                                                   |    23
    , 'toxicology|drug overdose|vasopressors|phenylephrine (Neosynephrine)' --                                                 |    21
    , 'toxicology|drug overdose|vasopressors|norepinephrine > 0.1 micrograms/kg/min' --                                        |    62
    , 'toxicology|drug overdose|vasopressors|norepinephrine <= 0.1 micrograms/kg/min' --                                       |    29
    , 'toxicology|drug overdose|vasopressors|epinephrine > 0.1 micrograms/kg/min' --                                           |     6
    , 'toxicology|drug overdose|vasopressors|epinephrine <= 0.1 micrograms/kg/min' --                                          |     2
    , 'toxicology|drug overdose|vasopressors|dopamine 5-15 micrograms/kg/min' --                                               |     7
    , 'toxicology|drug overdose|vasopressors|dopamine >15 micrograms/kg/min' --                                                |     3
    , 'toxicology|drug overdose|vasopressors' --                                                                               |    30
    , 'surgery|cardiac therapies|vasopressors|vasopressin' --                                                                  |   356
    , 'surgery|cardiac therapies|vasopressors|phenylephrine (Neosynephrine)' --                                                |  1000
    , 'surgery|cardiac therapies|vasopressors|norepinephrine > 0.1 micrograms/kg/min' --                                       |   390
    , 'surgery|cardiac therapies|vasopressors|norepinephrine <= 0.1 micrograms/kg/min' --                                      |   347
    , 'surgery|cardiac therapies|vasopressors|epinephrine > 0.1 micrograms/kg/min' --                                          |   117
    , 'surgery|cardiac therapies|vasopressors|epinephrine <= 0.1 micrograms/kg/min' --                                         |   178
    , 'surgery|cardiac therapies|vasopressors|dopamine  5-15 micrograms/kg/min' --                                             |   274
    , 'surgery|cardiac therapies|vasopressors|dopamine >15 micrograms/kg/min' --                                               |    23
    , 'surgery|cardiac therapies|vasopressors' --                                                                              |   596
    , 'renal|electrolyte correction|treatment of hypernatremia|vasopressin' --                                                 |     7
    , 'neurologic|therapy for controlling cerebral perfusion pressure|vasopressors|phenylephrine (Neosynephrine)' --           |   321
    , 'neurologic|therapy for controlling cerebral perfusion pressure|vasopressors|norepinephrine > 0.1 micrograms/kg/min' --  |   348
    , 'neurologic|therapy for controlling cerebral perfusion pressure|vasopressors|norepinephrine <= 0.1 micrograms/kg/min' -- |   374
    , 'neurologic|therapy for controlling cerebral perfusion pressure|vasopressors|epinephrine > 0.1 micrograms/kg/min' --     |    21
    , 'neurologic|therapy for controlling cerebral perfusion pressure|vasopressors|epinephrine <= 0.1 micrograms/kg/min' --    |   199
    , 'neurologic|therapy for controlling cerebral perfusion pressure|vasopressors|dopamine 5-15 micrograms/kg/min' --         |   277
    , 'neurologic|therapy for controlling cerebral perfusion pressure|vasopressors|dopamine > 15 micrograms/kg/min' --         |    20
    , 'neurologic|therapy for controlling cerebral perfusion pressure|vasopressors' --                                         |   172
    , 'gastrointestinal|medications|hormonal therapy (for varices)|vasopressin' --                                             |   964
    , 'cardiovascular|shock|vasopressors|vasopressin' --                                                                       | 11082
    , 'cardiovascular|shock|vasopressors|phenylephrine (Neosynephrine)' --                                                     | 13189
    , 'cardiovascular|shock|vasopressors|norepinephrine > 0.1 micrograms/kg/min' --                                            | 24174
    , 'cardiovascular|shock|vasopressors|norepinephrine <= 0.1 micrograms/kg/min' --                                           | 17467
    , 'cardiovascular|shock|vasopressors|epinephrine > 0.1 micrograms/kg/min' --                                               |  2410
    , 'cardiovascular|shock|vasopressors|epinephrine <= 0.1 micrograms/kg/min' --                                              |  2384
    , 'cardiovascular|shock|vasopressors|dopamine  5-15 micrograms/kg/min' --                                                  |  4822
    , 'cardiovascular|shock|vasopressors|dopamine >15 micrograms/kg/min' --                                                    |  1102
    , 'cardiovascular|shock|vasopressors' --                                                                                   |  9335
    , 'toxicology|drug overdose|agent specific therapy|beta blockers overdose|dopamine' --                             |    66
    , 'cardiovascular|ventricular dysfunction|inotropic agent|norepinephrine > 0.1 micrograms/kg/min' --                       |   537
    , 'cardiovascular|ventricular dysfunction|inotropic agent|norepinephrine <= 0.1 micrograms/kg/min' --                      |   411
    , 'cardiovascular|ventricular dysfunction|inotropic agent|epinephrine > 0.1 micrograms/kg/min' --                          |   274
    , 'cardiovascular|ventricular dysfunction|inotropic agent|epinephrine <= 0.1 micrograms/kg/min' --                         |   456
    , 'cardiovascular|shock|inotropic agent|norepinephrine > 0.1 micrograms/kg/min' --                                         |  1940
    , 'cardiovascular|shock|inotropic agent|norepinephrine <= 0.1 micrograms/kg/min' --                                        |  1262
    , 'cardiovascular|shock|inotropic agent|epinephrine > 0.1 micrograms/kg/min' --                                            |   477
    , 'cardiovascular|shock|inotropic agent|epinephrine <= 0.1 micrograms/kg/min' --                                           |   505
    , 'cardiovascular|shock|inotropic agent|dopamine <= 5 micrograms/kg/min' --                                        |  1103
    , 'cardiovascular|shock|inotropic agent|dopamine  5-15 micrograms/kg/min' --                                       |  1156
    , 'cardiovascular|shock|inotropic agent|dopamine >15 micrograms/kg/min' --                                         |   144
    , 'surgery|cardiac therapies|inotropic agent|dopamine <= 5 micrograms/kg/min' --                                   |   171
    , 'surgery|cardiac therapies|inotropic agent|dopamine  5-15 micrograms/kg/min' --                                  |    93
    , 'surgery|cardiac therapies|inotropic agent|dopamine >15 micrograms/kg/min' --                                    |     3
    , 'cardiovascular|myocardial ischemia / infarction|inotropic agent|norepinephrine > 0.1 micrograms/kg/min' --              |   688
    , 'cardiovascular|myocardial ischemia / infarction|inotropic agent|norepinephrine <= 0.1 micrograms/kg/min' --             |   670
    , 'cardiovascular|myocardial ischemia / infarction|inotropic agent|epinephrine > 0.1 micrograms/kg/min' --                 |   381
    , 'cardiovascular|myocardial ischemia / infarction|inotropic agent|epinephrine <= 0.1 micrograms/kg/min' --                |   357
    , 'cardiovascular|ventricular dysfunction|inotropic agent|dopamine <= 5 micrograms/kg/min' --                      |   886
    , 'cardiovascular|ventricular dysfunction|inotropic agent|dopamine  5-15 micrograms/kg/min' --                     |   649
    , 'cardiovascular|ventricular dysfunction|inotropic agent|dopamine >15 micrograms/kg/min' --                       |    86
    , 'cardiovascular|myocardial ischemia / infarction|inotropic agent|dopamine <= 5 micrograms/kg/min' --             |   346
    , 'cardiovascular|myocardial ischemia / infarction|inotropic agent|dopamine  5-15 micrograms/kg/min' --            |   520
    , 'cardiovascular|myocardial ischemia / infarction|inotropic agent|dopamine >15 micrograms/kg/min' --              |    54
    ) then 1 else 0 end) as vasopressor_flag
    from `physionet-data.eicu_crd.treatment`
    WHERE treatmentoffset <= 1440
    group by patientunitstayid
), endoscopy_table AS (
    SELECT 
    patientunitstayid,
    MAX(CASE WHEN treatmentstring IN(
        'gastrointestinal|endoscopy/gastric instrumentation|esophagogastroduodenoscopy',
        'gastrointestinal|endoscopy/gastric instrumentation|fiberoptic colonoscopy',
        'gastrointestinal|endoscopy/gastric instrumentation|esophagogastroduodenoscopy|with destruction of lesion',
        'gastrointestinal|endoscopy/gastric instrumentation|esophagogastroduodenoscopy|with chemocautery',
        'gastrointestinal|endoscopy/gastric instrumentation|esophagogastroduodenoscopy|with biopsy',
        'gastrointestinal|endoscopy/gastric instrumentation|fiberoptic colonoscopy|with biopsy',
        'gastrointestinal|endoscopy/gastric instrumentation|esophagogastroduodenoscopy|with banding',
        'gastrointestinal|endoscopy/gastric instrumentation|esophagogastroduodenoscopy|with PEG insertion',
        'gastrointestinal|endoscopy/gastric instrumentation|fiberoptic colonoscopy|with decompression',
        'gastrointestinal|endoscopy/gastric instrumentation|insertion of gastric balloon',
        'gastrointestinal|endoscopy/gastric instrumentation|fiberoptic colonoscopy|with banding',
        'gastrointestinal|endoscopy/gastric instrumentation|fiberoptic colonoscopy|with destruction of lesion',
        'gastrointestinal|endoscopy/gastric instrumentation|fiberoptic colonoscopy|with chemocautery'
        ) THEN 1 ELSE 0 END) AS endoscopy,
    MAX(CASE WHEN treatmentstring IN(
        'gastrointestinal|radiology, diagnostic and procedures|bleeding scan',
        'gastrointestinal|radiology, diagnostic and procedures|angiography|arteriography',
        'gastrointestinal|radiology, diagnostic and procedures|angiography'
        ) THEN 1 ELSE 0 END) AS angiography
    FROM `physionet-data.eicu_crd.treatment`
    WHERE treatmentoffset <= 1440
    GROUP BY patientunitstayid
), ppi_table AS(
    SELECT 
    patientunitstayid,
    MAX(CASE WHEN drugStartOffset <= 1440 THEN 1 ELSE 0 END) AS ppi
    FROM `physionet-data.eicu_crd.medication`
    WHERE LOWER(drugName) LIKE '%prazole%'
    GROUP BY patientunitstayid)

------------------------------------add admitoffset to cohort--------------------------------------------------
  
with adm as
(
  select
    patientunitstayid
    , min(chartoffset) as admitoffset
  from pivoted_vital p
  WHERE heartrate IS NOT NULL
  GROUP BY patientunitstayid
)

------------------------------------------------------sofa-----------------------------------------------------
CREATE TABLE
  `alien-works-293116.Datathon_AMI.mp_sofa` AS
  -- day 1 labs
WITH
  la AS (
  SELECT
    p.patientunitstayid,
    MIN(bilirubin) AS bilirubin_min_day1,
    MAX(bilirubin) AS bilirubin_max_day1,
    MIN(creatinine) AS creatinine_min_day1,
    MAX(creatinine) AS creatinine_max_day1,
    MIN(platelets) AS platelets_min_day1,
    MAX(platelets) AS platelets_max_day1
  FROM
    `physionet-data.eicu_crd_derived.pivoted_lab` p
  INNER JOIN
    `alien-works-293116.Datathon_AMI.eicu_GI_3` co
  ON
    p.patientunitstayid = co.patientunitstayid
    AND p.chartoffset > co.admitoffset + (-1*60)
    AND p.chartoffset <= co.admitoffset + (24*60)
  GROUP BY
    p.patientunitstayid )
  -- day 1 for medication interface
  ,
  mi AS (
  SELECT
    p.patientunitstayid,
    MAX(norepinephrine) AS norepinephrine,
    MAX(epinephrine) AS epinephrine,
    MAX(dopamine) AS dopamine,
    MAX(dobutamine) AS dobutamine,
    MAX(phenylephrine) AS phenylephrine,
    MAX(vasopressin) AS vasopressin,
    MAX(milrinone) AS milrinone
  FROM
    `physionet-data.eicu_crd_derived.pivoted_med` p
  INNER JOIN
    `alien-works-293116.Datathon_AMI.eicu_GI_3` co
  ON
    p.patientunitstayid = co.patientunitstayid
    AND p.chartoffset > co.admitoffset + (-1*60)
    AND p.chartoffset <= co.admitoffset + (24*60)
  GROUP BY
    p.patientunitstayid )
  -- day 1 for infusions
  ,
  inf AS (
  SELECT
    p.patientunitstayid,
    MAX(norepinephrine) AS norepinephrine,
    MAX(epinephrine) AS epinephrine,
    MAX(dopamine) AS dopamine,
    MAX(dobutamine) AS dobutamine,
    MAX(phenylephrine) AS phenylephrine,
    MAX(vasopressin) AS vasopressin,
    MAX(milrinone) AS milrinone
  FROM
    `physionet-data.eicu_crd_derived.pivoted_infusion` p
  INNER JOIN
    `alien-works-293116.Datathon_AMI.eicu_GI_3` co
  ON
    p.patientunitstayid = co.patientunitstayid
    AND p.chartoffset > co.admitoffset + (-1*60)
    AND p.chartoffset <= co.admitoffset + (24*60)
  GROUP BY
    p.patientunitstayid )
  -- combine medication + infusion tables
  ,
  med AS (
  SELECT
    pat.patientunitstayid,
    GREATEST(mi.norepinephrine, inf.norepinephrine) AS norepinephrine_day1,
    GREATEST(mi.epinephrine, inf.epinephrine) AS epinephrine_day1,
    GREATEST(mi.dopamine, inf.dopamine) AS dopamine_day1,
    GREATEST(mi.dobutamine, inf.dobutamine) AS dobutamine_day1,
    GREATEST(mi.phenylephrine, inf.phenylephrine) AS phenylephrine_day1,
    GREATEST(mi.vasopressin, inf.vasopressin) AS vasopressin_day1,
    GREATEST(mi.milrinone, inf.milrinone) AS milrinone_day1
  FROM
    `physionet-data.eicu_crd.patient` pat
  LEFT JOIN
    mi
  ON
    pat.patientunitstayid = mi.patientunitstayid
  LEFT JOIN
    inf
  ON
    pat.patientunitstayid = inf.patientunitstayid )
  -- get vital signs
  ,
  vi AS (
  SELECT
    p.patientunitstayid,
    MIN(heartrate) AS heartrate_min_day1,
    MAX(heartrate) AS heartrate_max_day1,
    MIN(coalesce(ibp_mean,
        nibp_mean)) AS map_min_day1,
    MAX(coalesce(ibp_mean,
        nibp_mean)) AS map_max_day1,
    MIN(temperature) AS temperature_min_day1,
    MAX(temperature) AS temperature_max_day1,
    MIN(spo2) AS spo2_min_day1,
    MAX(spo2) AS spo2_max_day1
  FROM
    `physionet-data.eicu_crd_derived.pivoted_vital` p
  INNER JOIN
    `alien-works-293116.Datathon_AMI.eicu_GI_3` co
  ON
    p.patientunitstayid = co.patientunitstayid
    AND p.chartoffset > co.admitoffset + (-1*60)
    AND p.chartoffset <= co.admitoffset + (24*60)
  WHERE
    heartrate IS NOT NULL
    OR ibp_mean IS NOT NULL
    OR nibp_mean IS NOT NULL
    OR temperature IS NOT NULL
    OR spo2 IS NOT NULL
  GROUP BY
    p.patientunitstayid )
  -- calculate SOFA
  ,
  sf AS (
  SELECT
    pt.patientunitstayid,
    CASE
      WHEN aav.pao2 = -1 THEN 0
      WHEN aav.fio2 = -1 THEN 0
    -- ventilated
      WHEN apv.VENTDAY1 = 1 THEN CASE
      WHEN (aav.pao2 / aav.fio2 * 100) < 100 THEN 4
      WHEN (aav.pao2 / aav.fio2 * 100) < 200 THEN 3
    ELSE
    0
  END
      WHEN (aav.pao2 / aav.fio2 * 100) < 300 THEN 2
      WHEN (aav.pao2 / aav.fio2 * 100) < 400 THEN 1
    ELSE
    0
  END
    AS sofa_respiration
    -- Coagulation
    ,
    CASE
      WHEN la.platelets_min_day1 < 20 THEN 4
      WHEN la.platelets_min_day1 < 50 THEN 3
      WHEN la.platelets_min_day1 < 100 THEN 2
      WHEN la.platelets_min_day1 < 150 THEN 1
    ELSE
    0
  END
    AS sofa_coagulation
    -- Liver
    ,
    CASE
    -- Bilirubin checks in mg/dL
      WHEN la.bilirubin_max_day1 >= 12.0 THEN 4
      WHEN la.bilirubin_max_day1 >= 6.0 THEN 3
      WHEN la.bilirubin_max_day1 >= 2.0 THEN 2
      WHEN la.bilirubin_max_day1 >= 1.2 THEN 1
    ELSE
    0
  END
    AS sofa_liver
    -- Cardiovascular
    ,
    CASE
      WHEN med.epinephrine_day1 > 0 OR med.norepinephrine_day1 > 0 OR med.dopamine_day1 > 0 OR med.dobutamine_day1 > 0 THEN 3
    -- when rate_dopamine >  5 or rate_epinephrine <= 0.1 or rate_norepinephrine <= 0.1 then 3
      WHEN vi.map_min_day1 < 70 THEN 1
    ELSE
    0
  END
    AS sofa_cardiovascular
    -- Neurological failure (GCS)
    ,
    CASE
      WHEN aav.meds = -1 OR aav.eyes = -1 OR aav.motor = -1 OR aav.verbal = -1 THEN 0
      WHEN aav.meds = 1 THEN 0
      WHEN (aav.eyes + aav.motor + aav.verbal >= 13 AND aav.eyes + aav.motor + aav.verbal <= 14) THEN 1
      WHEN (aav.eyes + aav.motor + aav.verbal >= 10
      AND aav.eyes + aav.motor + aav.verbal <= 12) THEN 2
      WHEN (aav.eyes + aav.motor + aav.verbal >= 6 AND aav.eyes + aav.motor + aav.verbal <= 9) THEN 3
      WHEN aav.eyes + aav.motor + aav.verbal < 6 THEN 4
    -- when coalesce(aav.eyes,aav.motor,aav.verbal) is null then null
    ELSE
    0
  END
    AS sofa_cns
    -- Renal failure - high creatinine or low urine output
    ,
    CASE
      WHEN (la.creatinine_max_day1 >= 5.0) THEN 4
      WHEN aav.urine >= 0
    AND aav.urine < 200 THEN 4
      WHEN (la.creatinine_max_day1 >= 3.5 AND la.creatinine_max_day1 < 5.0) THEN 3
      WHEN aav.urine >= 200
    AND aav.urine < 500 THEN 3
      WHEN (la.creatinine_max_day1 >= 2.0 AND la.creatinine_max_day1 < 3.5) THEN 2
      WHEN (la.creatinine_max_day1 >= 1.2
      AND la.creatinine_max_day1 < 2.0) THEN 1
    -- when coalesce(UrineOutput, creatinine_max_day1) is null then null
    ELSE
    0
  END
    AS sofa_renal
  FROM
    `physionet-data.eicu_crd.patient` pt
  LEFT JOIN
    la
  ON
    pt.patientunitstayid = la.patientunitstayid
  LEFT JOIN
    med
  ON
    pt.patientunitstayid = med.patientunitstayid
  LEFT JOIN
    vi
  ON
    pt.patientunitstayid = vi.patientunitstayid
  LEFT JOIN
    `physionet-data.eicu_crd.apacheapsvar` aav
  ON
    pt.patientunitstayid = aav.patientunitstayid
  LEFT JOIN
    `physionet-data.eicu_crd.apachepredvar` apv
  ON
    pt.patientunitstayid = apv.patientunitstayid )
SELECT
  sf.patientunitstayid,
  sf.sofa_cardiovascular,
  sf.sofa_renal,
  sf.sofa_cns,
  sf.sofa_coagulation,
  sf.sofa_liver,
  sf.sofa_respiration
  -- calculate total
  ,
  sf.sofa_cardiovascular + sf.sofa_renal + sf.sofa_cns + sf.sofa_coagulation + sf.sofa_liver + sf.sofa_respiration AS sofa
FROM
  sf
ORDER BY
  sf.patientunitstayid;
  

N = 200859 all eicu participants
N = 9418.  number of patients with GI bleeding

----------------------------add condition1--------------------------------------------
AND p.patientunitstayid NOT IN(
    SELECT
    patientunitstayid 
    FROM `physionet-data.eicu_crd.admissiondx`
    WHERE admitDxName IN('Bleeding, GI from esophageal varices/portal hypertension',
    'Bleeding-variceal, surgery for (excluding vascular shunting-see surgery for portosystemic shunt)')
) 

N3 = 7850

-----------------------------add condition2--------------------------------------------

AND p.patientunitstayid NOT IN(
    SELECT
    patientunitstayid 
    FROM `physionet-data.eicu_crd.admissiondx`
    WHERE admitDxName IN('Bleeding, GI from esophageal varices/portal hypertension',
    'Bleeding-variceal, surgery for (excluding vascular shunting-see surgery for portosystemic shunt)')
    UNION ALL
    SELECT patientunitstayid FROM `physionet-data.eicu_crd.diagnosis`
    WHERE diagnosisString = 'gastrointestinal|GI bleeding / PUD|upper GI bleeding|varices'
) 

N4 = 7609
-----------------------------add condition3---------------------------------------------

AND p.patientunitstayid IN(
    SELECT 
    patientunitstayid
    FROM `physionet-data.eicu_crd.patient`
    WHERE hospitalAdmitSource = 'Emergency Department'
    AND hospitalAdmitOffset BETWEEN -1440 AND 0
)

N5 = 3805
        
SELECT 
p.*,
d.ihd,
d.diabetes,
d.hypertension,
d.ckd,
d.malignancy,
sf.sofa,
l.HEMATOCRIT_max,
l.HEMATOCRIT_min,
l.HEMOGLOBIN_min,
l.HEMOGLOBIN_max,
l.PLATELET_min,
l.PLATELET_max,
l.WBC_min,
l.WBC_max,
l.ANIONGAP_min,
l.ANIONGAP_max,
l.BICARBONATE_min,
l.BICARBONATE_max,
l.BUN_min,
l.BUN_max,
l.CALCIUM_min,
l.CALCIUM_max,
l.CHLORIDE_min,
l.CHLORIDE_max,
l.CREATININE_min,
l.CREATININE_max,
l.SODIUM_min,
l.SODIUM_max,
l.POTASSIUM_min,
l.POTASSIUM_max,
l.INR_min,
l.INR_max,
l.PT_min,
l.PT_max,
l.PTT_min,
l.PTT_max,
l.GLUCOSE_min,
l.GLUCOSE_max,
l.LACTATE_min,
l.LACTATE_max,
v.heart_rate_min,
v.heart_rate_max,
v.heart_rate_mean,
v.sbp_min,
v.sbp_max,
v.sbp_mean,
v.dbp_min,
v.dbp_max,
v.dbp_mean,
v.mbp_min,
v.mbp_max,
v.mbp_mean,
v.resp_rate_min,
v.resp_rate_max,
v.resp_rate_mean,
v.temperature_min,
v.temperature_max,
v.temperature_mean,
v.spo2_min,
v.spo2_max,
v.spo2_mean,
vaso.vasopressor_flag,
t.transfusion_flag,
e.endoscopy,
e.angiography,
pt.ppi,
ppt.apachescore
FROM `alien-works-293116.Datathon_AMI.eicu_GI_3` p
LEFT JOIN `alien-works-293116.Datathon_AMI.eicu_diagnosis` d
    ON p.patientunitstayid=d.patientunitstayid
LEFT JOIN `alien-works-293116.Datathon_AMI.mp_sofa` sf
    ON p.patientunitstayid=sf.patientunitstayid
LEFT JOIN `alien-works-293116.Datathon_AMI.eicu_GI_labtest` l
    ON p.patientunitstayid=l.patientunitstayid
LEFT JOIN `alien-works-293116.Datathon_AMI.eicu_GI_vitalsign` v 
    ON p.patientunitstayid=v.patientunitstayid
LEFT JOIN `alien-works-293116.Datathon_AMI.eicu_vasopressor` vaso
    ON p.patientunitstayid=vaso.patientunitstayid
LEFT JOIN `alien-works-293116.Datathon_AMI.eicu_rcb` t
    ON p.patientunitstayid=t.patientunitstayid
LEFT JOIN `alien-works-293116.Datathon_AMI.eicu_endoscopy` e
    ON p.patientunitstayid=e.patientunitstayid
LEFT JOIN `alien-works-293116.Datathon_AMI.eicu_ppi` pt
    ON p.patientunitstayid=pt.patientunitstayid
LEFT JOIN `physionet-data.eicu_crd.apachepatientresult` ppt
    ON p.patientunitstayid=ppt.patientunitstayid
