

***Start file: August 2024
***Update with some small changes January 2025 (fix heat pump and ODIN mobility data)
***Update March 2025, focus on working age population (main earner = 18-64 year old)
***Cody Hochstenbach

*this code creates a dataset with all individuals, their households and their housing situation
*year = 2019 (selected as it is pre-covid for mobility analyses)

*I am particularly interested in housing features:
*size in sqm
*typology
*construction year
*urbanity (of neighbourhood)
*distance to amenities
*mobility patterns

*In addition, I will also stratify by
*household size and composition
*income groups 

**********************************************************************************
**the data are to be found in different datasets
**I will retrieve them and store them in separate files (temporary)
**upon completion, these separate files can be deleted and continue with master

**retrieving all object codes plus spatial identifiers
clear all
use "G:\BouwenWonen\VSLGWBTAB\geconverteerde data\VSLGWB2023TAB03V1.dta" 
keep soortobjectnummer rinobjectnummer gem2019 wc2019 bc2019
recast str32 rinobjectnummer
save "H:\Cody Hochstenbach\social ecological\housingset2019.dta", replace

**
**retrieve size and construction year of dwelling
clear all
import spss "G:\BouwenWonen\LEVCYCLWOONNIETWOONBUS\LEVCYCLWOONNIETWOONBUSV2023122.sav"
gen aanvang = real(AANVLEVCYCLWOONNIETWOON)
gen eind = real(EINDLEVCYCLWOONNIETWOON)
keep if aanvang<=20190101 
keep if eind>20190101 //i.e. these two rules indicate situation of property on Jan-1 2019
rename SOORTOBJECTNUMMER soortobjectnummer
rename RINOBJECTNUMMER rinobjectnummer
gen construction2019 = real(VBOBOUWJAAR) //construction year
gen size2019 = real(VBOOPPERVLAKTE) //size in sqm
gen instock2019 = real(INVOORRAAD) //dummy whether unit is in stock
keep soortobjectnummer rinobjectnummer construction2019 size2019 instock2019
recast str32 rinobjectnummer
save "H:\Cody Hochstenbach\social ecological\levcycl2019.dta", replace

**retrieve housing tenure (ownership, social rental, private rental)
clear all
import spss "G:\BouwenWonen\EIGENDOMTAB\EIGENDOM2019TABV3.sav"
rename SOORTOBJECTNUMMER soortobjectnummer
rename RINOBJECTNUMMER rinobjectnummer
gen tenure2019=.
replace tenure2019=1 if TypeEigendom=="E" //ownership
replace tenure2019=2 if TypeEigendom=="H" & TypeEigenaar=="C" //social rental
replace tenure2019=3 if TypeEigendom=="H" & TypeEigenaar=="V" //private rental
keep soortobjectnummer rinobjectnummer tenure2019
recast str32 rinobjectnummer
save "H:\Cody Hochstenbach\social ecological\tenure2019.dta", replace

**retrieve typology (nb we have to use 2020 data here as data does not exist for 2019)
clear all
import spss "G:\BouwenWonen\VBOWONINGTYPETAB\VBOWONINGTYPE2020TABV2.sav"
rename SOORTOBJECTNUMMER soortobjectnummer
rename RINOBJECTNUMMER rinobjectnummer
gen typology2019 = real(VBOWoningtype) //1=vrijstaand, 2=2-onder-1-kap, 3=hoek, 4=tussen, 5=appartement
replace typology2019 = . if typology2019==99
drop VBOWoningtype
save "H:\Cody Hochstenbach\social ecological\typology2019.dta", replace

**retrieve neighbourhood density
clear all
import excel using "K:\Utilities\Wijk_en_Buurtstatistieken\KERNCIJFERS wijk en buurt\kwb-2019.xlsx", firstrow
keep if recs=="Buurt" //keep neighbourhoods
keep gwb_code_8 ste_mvs ste_oad regio gm_naam
rename gwb_code_8 bc2019
rename regio name_nbhd2019
rename gm_naam municipality2019
gen density2019 = real(ste_mvs) //five fold density category
gen addresses2019 = real(ste_oad) //number of addresses per square kilometer (basis for density category)
save "H:\Cody Hochstenbach\social ecological\kwb2019.dta", replace

**retrieve house value (WOZ)
clear all
import spss "G:\BouwenWonen\EIGENDOMWOZBAGTAB\2019\EIGENDOMWOZBAG2019TABV1.sav"
rename SOORTOBJECTNUMMER soortobjectnummer
rename RINOBJECTNUMMER rinobjectnummer
rename WOZWAARDEOBJECTBAG value2019
keep soortobjectnummer rinobjectnummer value2019
save "H:\Cody Hochstenbach\social ecological\value2019.dta", replace

**retrieve energy source and consumption (note: heat pump data for 2019 is skewed, capturing only multifamily pumps //use 2021 data)
clear all
import spss "G:\IndustrieEnergie\ENERGIEVERBRUIKTABZK\ENERGIEVERBRUIK2019TABV2ZK.sav"
rename SOORTOBJECTNUMMER soortobjectnummer
rename RINOBJECTNUMMER rinobjectnummer
rename GASSJV gas2019 //note this is temperature corrected gas use
rename ELEK electricity2019
rename ELEKNETTO netelectricity2019 //this is electricity consumptions minus solar energy fed back to the system
rename ZONVERMOGEN31DEC solarcapacity2019 //based on Dec-31st
gen solar_dummy2019 = 0
replace solar_dummy2019 = 1 if ZONPV=="1"
gen heatpump_dummy2019 = 0
replace heatpump_dummy2019 = 1 if GASBRON=="WP"
gen cityheating_dummy2019 = 0
replace cityheating_dummy2019 = 1 if GASBRON=="SW"
gen warmteschatting_SW = .
replace warmteschatting_SW=WARMTESCHATTING if GASBRON=="SW"

keep soortobjectnummer rinobjectnummer gas2019 electricity2019 netelectricity2019 solarcapacity2019 solar_dummy2019 cityheating_dummy2019 warmteschatting_SW
save "H:\Cody Hochstenbach\social ecological\energy2019.dta", replace

*2021 energy data for heat pumps (data up to 2020 is skewed, so use this instead (nb: slight skew))
clear all
import spss "G:\IndustrieEnergie\ENERGIEVERBRUIKTABZK\ENERGIEVERBRUIK2021TABV2ZK.sav"
rename SOORTOBJECTNUMMER soortobjectnummer
rename RINOBJECTNUMMER rinobjectnummer
gen heatpump_dummy2019 = 0
replace heatpump_dummy2019 = 1 if GASBRON=="WP"
keep soortobjectnummer rinobjectnummer heatpump_dummy2019
save "H:\Cody Hochstenbach\social ecological\heatpump2019.dta", replace

**retrieve distance to train station (by road)
clear all
import spss "G:\BouwenWonen\NABIJHEIDVERKEERTAB\2019\NABIJHEIDVERKEER2019TABV2.sav"
rename SOORTOBJECTNUMMER soortobjectnummer
rename RINOBJECTNUMMER rinobjectnummer
rename VZAFSTANDTREINST distance_train2019
keep soortobjectnummer rinobjectnummer distance_train2019
save "H:\Cody Hochstenbach\social ecological\distance_train2019.dta", replace

**retrieve distance to department store/supermarket (by road)
clear all
import spss "G:\BouwenWonen\NABIJHEIDDETAILHTAB\2019\NABIJHEIDDETAILH2019TABV1.sav"
rename SOORTOBJECTNUMMER soortobjectnummer
rename RINOBJECTNUMMER rinobjectnummer
rename VZAFSTANDWARENH distance_depstore2019
rename VZAFSTANDGRSUPERM distance_supermarket2019
keep soortobjectnummer rinobjectnummer distance_depstore2019 distance_supermarket2019
save "H:\Cody Hochstenbach\social ecological\distance_store2019.dta", replace

**retrieve distance to higher education (by road)
clear all
import spss "G:\BouwenWonen\NABIJHEIDONDERWIJSTAB\2019\NABIJHEIDONDERWIJS2019TABV2.sav"
rename SOORTOBJECTNUMMER soortobjectnummer
rename RINOBJECTNUMMER rinobjectnummer
rename VZAFSTANDVO distance_middleschool2019
keep soortobjectnummer rinobjectnummer distance_middleschool2019
save "H:\Cody Hochstenbach\social ecological\distance_school2019.dta", replace


**now couple all these files into one housing dataset
clear all
use "H:\Cody Hochstenbach\social ecological\housingset2019.dta"
sort soortobjectnummer rinobjectnummer
joinby soortobjectnummer rinobjectnummer using "H:\Cody Hochstenbach\social ecological\levcycl2019.dta", unmatched(master)
drop _merge
joinby soortobjectnummer rinobjectnummer using "H:\Cody Hochstenbach\social ecological\tenure2019.dta", unmatched(master)
drop _merge
joinby soortobjectnummer rinobjectnummer using "H:\Cody Hochstenbach\social ecological\typology2019.dta", unmatched(master)
drop _merge
joinby soortobjectnummer rinobjectnummer using "H:\Cody Hochstenbach\social ecological\value2019.dta", unmatched(master)
drop _merge
joinby soortobjectnummer rinobjectnummer using "H:\Cody Hochstenbach\social ecological\energy2019.dta", unmatched(master)
drop _merge
joinby soortobjectnummer rinobjectnummer using "H:\Cody Hochstenbach\social ecological\heatpump2019.dta", unmatched(master)
drop _merge
joinby soortobjectnummer rinobjectnummer using "H:\Cody Hochstenbach\social ecological\distance_train2019.dta", unmatched(master)
drop _merge
joinby soortobjectnummer rinobjectnummer using "H:\Cody Hochstenbach\social ecological\distance_store2019.dta", unmatched(master)
drop _merge
joinby soortobjectnummer rinobjectnummer using "H:\Cody Hochstenbach\social ecological\distance_school2019.dta", unmatched(master)
drop _merge

sort bc2019
joinby bc2019 using "H:\Cody Hochstenbach\social ecological\kwb2019.dta", unmatched(master)
drop _merge 

**some variable manipulations
winsor2 size2019, suffix(_w1) cuts(1 99) //size in sqm winsorized at 1%
winsor2 size2019, suffix(_w2) cuts(2 98) //size in sqm winsorized at 2%
winsor2 size2019, suffix(_wh) cuts(.5 99.6) //size in sqm winsorized at .5% (half=h)

*
gen const_cat7 = . //categorization of construction years
replace const_cat7 = 1 if construction2019>=1000 & construction2019<=1945
replace const_cat7 = 2 if construction2019>=1946 & construction2019<=1964
replace const_cat7 = 3 if construction2019>=1965 & construction2019<=1974
replace const_cat7 = 4 if construction2019>=1975 & construction2019<=1991
replace const_cat7 = 5 if construction2019>=1992 & construction2019<=2005
replace const_cat7 = 6 if construction2019>=2006 & construction2019<=2014
replace const_cat7 = 7 if construction2019>=2015 & construction2019<=2023
*
gen const_cat6 = . //alternative categorization consturction years
replace const_cat6 = 1 if construction2019>=1000 & construction2019<=1945
replace const_cat6 = 2 if construction2019>=1946 & construction2019<=1964
replace const_cat6 = 3 if construction2019>=1965 & construction2019<=1974
replace const_cat6 = 4 if construction2019>=1975 & construction2019<=1991
replace const_cat6 = 5 if construction2019>=1992 & construction2019<=2005
replace const_cat6 = 6 if construction2019>=2006 & construction2019<=2023

*
gen typology4_2019 = . // 4-fold typology of housing type
replace typology4_2019 = 1 if typology2019==1 //detached housing
replace typology4_2019 = 2 if typology2019==2|typology2019==3 //semi-detached + corner house
replace typology4_2019 = 3 if typology2019==4 //row house
replace typology4_2019 = 4 if typology2019==5 //apartment

*energy vars - data cleaning
replace solarcapacity2019 = 0 if solarcapacity2019 ==. //in our calculations below we also want to include dwellings without solar (i.e. means of solar capacity include those without solar)
replace warmteschatting_SW = 0 if warmteschatting_SW==. //same for warmteschatting (i.e. include those without city heating)

**selection var of dwellings to include in the analysis
gen selected_house = 0
replace selected_house = 1 if instock2019==1 & (typology2019>=1 & typology2019<=5) & (density2019>=1 & density2019<=5) & (const_cat6>=1 & const_cat6<=7) & size2019!=. & electricity2019!=. & solar_dummy2019!=.
tab selected_house

**impute distance var
**in a small % of cases, the distance to a dwelling is unknown. We can impute this based on the mean distance of other dwellings in the neighbourhood
sort bc2019
egen distance_train2019_imp = mean(distance_train2019), by(bc2019)
summ distance_train2019 distance_train2019_imp if selected_house==1 //check: mean is 25 meters difference for real observations and imputed ones (5007m 5032m) - this is close enough for imputing
egen distance_middleschool2019_imp = mean (distance_middleschool2019), by(bc2019)
summ distance_middleschool2019 distance_middleschool2019_imp if selected_house==1 // (2303m vs 2312m)
egen distance_depstore2019_imp = mean (distance_depstore2019), by(bc2019)
summ distance_depstore2019 distance_depstore2019_imp if selected_house==1  // (2527m vs 2535m)
egen distance_supermarket2019_imp = mean (distance_supermarket2019), by(bc2019)
summ distance_supermarket2019 distance_supermarket2019_imp if selected_house==1 // (837m vs 839m)

replace distance_train2019 = distance_train2019_imp if distance_train2019==. & selected_house==1 //add to main var in case of missing
replace distance_middleschool2019 = distance_middleschool2019_imp if distance_middleschool2019==. & selected_house==1 //add to main var in case of missing
replace distance_depstore2019 = distance_depstore2019_imp if distance_depstore2019==. & selected_house==1 //add to main var in case of missing
replace distance_supermarket2019 = distance_supermarket2019_imp if distance_supermarket2019==. & selected_house==1 //add to main var in case of missing
*this adds 255,154 cases (from 7.5m to 7.7m)
drop distance_train2019_imp distance_middleschool2019_imp distance_depstore2019_imp distance_supermarket2019_imp

sort soortobjectnummer rinobjectnummer
save "H:\Cody Hochstenbach\social ecological\housing master 2019.dta", replace //this master file contains all dwellings and all available information
**manually delete the other saved files from folder

*clear all
*use "H:\Cody Hochstenbach\social ecological\housing master 2019.dta"
*sort soortobjectnummer rinobjectnummer
*******************************************************************************************************************************
*******************************************************************************************************************************
*******************************************************************************************************************************
*******************************************************************************************************************************
*the other side is the residential aspect
*we are particularly interested in household size and household income

**retrieve individuals in 2019
clear all
use "G:\Bevolking\GBAPERSOONTAB\2019\geconverteerde data\GBAPERSOON2019TABV1.DTA" 
keep rinpersoons rinpersoon gbageslacht gbaherkomstgroepering gbageneratie gbageboortejaar
compress
save "H:\Cody Hochstenbach\social ecological\personset2019.dta", replace

**retrieve personal income and household identifier
**nb: likely we don't use personal income, just household income
clear all
use "G:\InkomenBestedingen\INPATAB\geconverteerde data\INPA2019TABV3.dta"
keep rinpersoons rinpersoon rinpersoonshkw rinpersoonhkw INPP100PBRUT inppersbrut
rename INPP100PBRUT p_pinc2019 //percentiles of personal income (gross)
rename inppersbrut pinc2019 //personal income (gross)
save "H:\Cody Hochstenbach\social ecological\pincome2019.dta", replace

**retrieve household income
clear all
use "G:\InkomenBestedingen\INHATAB\geconverteerde data\INHA2019TABV2.dta" 
keep rinpersoonshkw rinpersoonhkw inhbrutinkh INHP100HBRUT inhgestinkh INHP100HGESTES
rename inhbrutinkh hinc2019 //gross household income
rename INHP100HBRUT p_hinc2019 //percentile of household income gross
rename inhgestinkh hinceq2019 //equivalized household income
rename INHP100HGESTES p_hinceq2019 //percentile of equivalized household income

save "H:\Cody Hochstenbach\social ecological\hincome2019.dta", replace

**retrieve address of individual
*this one should be used to link demographic indicators (individual/household) to housing indicators
clear all 
use "G:\Bevolking\GBAADRESOBJECTBUS\geconverteerde data\GBAADRESOBJECT2023BUSV1.DTA" 
gen aanvang = real(gbadatumaanvangadreshouding)
gen eind = real(gbadatumeindeadreshouding)
keep if aanvang<=20190101 & eind>20190101 //this indicates living at address at Jan-1 2021 (residence started before or on that data, ended after/continues)
keep rinpersoons rinpersoon soortobjectnummer rinobjectnummer
save "H:\Cody Hochstenbach\social ecological\address2019.dta", replace


**odin dataset (mobility survey)
**each row is a trip nested in individuals (i.e. one individual can have multiple trips/rows)
clear all
import spss "G:\VerkeerVervoer\ODIN\ODIN2019V3.SAV"
rename RINPERSOONS rinpersoons
rename RINPERSOON rinpersoon

keep if Rit==1

gen n_cars = HHAuto //number of cars in the respondent's household (note: category 9 is actually 9 or more, here we just assume it's just 9)
replace n_cars = . if n_cars==10 //10 is categorized as missing

gen n_carpassengers = RAantIn  if KRvm==1|KRvm==2 //number of passengers in car trip (note: category 9 is actually 9 or more, here we just assume it's just 9)
replace n_carpassengers = . if n_carpassengers==10 //cats 10 and 11 are missings
replace n_carpassengers = . if n_carpassengers==11 



**distance travel by modes
gen dist_car_d = (AfstR + AfstRBL)/10 if KRvm==1 //distance (in km) travelled by car as driver (_d)
gen dist_car_p = (AfstR + AfstRBL)/10 if KRvm==2 //distance (in km) travelled by car as passenger (_p)
gen dist_train = (AfstR + AfstRBL)/10 if KRvm==3 //distance (in km) travelled in train 
gen dist_bustrammetro = (AfstR + AfstRBL)/10 if KRvm==4 //distance in bus, tram, metro
gen dist_cycle = (AfstR + AfstRBL)/10 if KRvm==5 //distance (in km) travelled cycling
gen dist_walk = (AfstR + AfstRBL)/10 if KRvm==6 //distance (in km) travelled walking
gen dist_car_dpp = dist_car_d/n_carpassengers //distance (in km) travelled by car as driver per passenger
gen dist_car_ppp = dist_car_p/n_carpassengers //distance (in km) travelled by car as passenger per passenger

summ dist_car_d dist_car_p dist_train dist_bustrammetro dist_cycle dist_walk dist_car_dpp dist_car_ppp [aweight=FactorP]

*number of trips by modes (dummy var)
gen car_trip_d = 0 
replace car_trip_d = 1 if KRvm==1 //dummy to count number of car trips as driver
gen car_trip_p = 0
replace car_trip_p = 1 if KRvm==2 //dummy to count number of car trips as passenger
gen train_trip = 0
replace train_trip = 1 if KRvm==3 // dummy to count number of train trips
gen bustrammetro_trip = 0
replace bustrammetro_trip = 1 if KRvm==4 // dummy to count number of bus tram metro trips
gen cycle_trip = 0
replace cycle_trip = 1 if KRvm==5 //dummy to count number of cycling trips
gen walk_trip = 0
replace walk_trip = 1 if KRvm==6 //dummy to count number of walking trips

tab car_trip_d
tab car_trip_p
tab train_trip
tab bustrammetro_trip
tab walk_trip
tab cycle_trip

*income var 
rename HHGestInkG inc_odin //also uses equivalized household income
replace inc_odin=. if inc_odin==11 //11 is missing category

*day is workday
gen workday = 0
replace workday = 1 if Feestdag==0 & Weekdag>=2 & Weekdag<=6 ///dummy to exclude holidays and weekends (Sunday==1 and Saturday==7 in original var)

*keep if workday==1 //only include trips on weekdays (for comparability)

summ dist_car_d dist_car_p dist_train dist_bustrammetro dist_cycle dist_walk dist_car_dpp dist_car_ppp [aweight=FactorP]
summ dist_car_d dist_car_p dist_train dist_bustrammetro dist_cycle dist_walk dist_car_dpp dist_car_ppp
sort rinpersoons rinpersoon
collapse (first) FactorP FactorV FactorH n_cars inc_odin (sum) dist_car_d dist_car_p dist_train dist_bustrammetro dist_cycle dist_walk dist_car_dpp dist_car_ppp car_trip_d car_trip_p train_trip bustrammetro_trip cycle_trip walk_trip (mean) n_carpassengers, by(rinpersoons rinpersoon) //collapse to person level
*this file reports per person the total distance travelled per transport mode on a given day; as well as the total number of trips per transport mode per day
total dist_car_d dist_car_p dist_train car_trip_d car_trip_p train_trip 

gen dist_car = dist_car_d + dist_car_p //combine car travel (driver or passenger)
gen dist_carpp = dist_car_dpp + dist_car_ppp //combine car travel per passenger
gen dist_transit = dist_train + dist_bustrammetro // combine different transit modes

gen car_trip = car_trip_d + car_trip_p
gen transit_trip = train_trip + bustrammetro_trip

save "H:\Cody Hochstenbach\social ecological\odin2019.dta", replace


*******************************************************************************************************************************

****
**now we can link these files
clear all
use "H:\Cody Hochstenbach\social ecological\personset2019.dta"
sort rinpersoons rinpersoon
joinby rinpersoons rinpersoon using "H:\Cody Hochstenbach\social ecological\pincome2019.dta", unmatched(master)
drop _merge
joinby rinpersoons rinpersoon using "H:\Cody Hochstenbach\social ecological\address2019.dta", unmatched(master)
drop _merge
joinby rinpersoons rinpersoon using "H:\Cody Hochstenbach\social ecological\odin2019.dta", unmatched(master)
drop _merge

sort rinpersoonshkw rinpersoonhkw
joinby rinpersoonshkw rinpersoonhkw using "H:\Cody Hochstenbach\social ecological\hincome2019.dta", unmatched(master)
drop _merge

**household identifier (head of household)
gen hhd_head = 0
replace hhd_head = 1 if rinpersoon == rinpersoonhkw

**number of members in household
gen present=1
bysort rinpersoonhkw: egen n_hhdmem2019 = total(present==1)
drop present

**number of adult/child members in household
gen birthyear = real(gbageboortejaar)
gen age2019 = 2019-1-birthyear
gen adult=0
replace adult=1 if age2019>=18 & age2019!=.
gen child=0
replace child=1 if age2019>=0 & age2019<18
bysort rinpersoonhkw: egen n_adultmem2019 = total(adult==1)
bysort rinpersoonhkw: egen n_childmem2019 = total(child==1)

tab n_adultmem2019 if n_adultmem2019>20
drop if n_adultmem2019>20 & n_adultmem2019<10000000 

summ p_hinc2019
tab n_adultmem2019



*aggregate mobility data to the household level
bysort rinpersoonhkw: egen FactorH_odin = max(FactorH) //household weight
bysort rinpersoonhkw: egen FactorP_odin = sum(FactorP) //household weight
bysort rinpersoonhkw: egen FactorV_odin = sum(FactorV) //household weight

bysort rinpersoonhkw: egen n_carshhd = max(n_cars) //number of cars in the household, this was already a hhd variable so use max instead of sum
replace n_carshhd = . if FactorH_odin == .

bysort rinpersoonhkw: egen inc_decile_odin = max(inc_odin) //equivalized hhd income from odin survey (this was hhd var so use max instead of sum)
replace inc_decile_odin = . if FactorH_odin == .

bysort rinpersoonhkw: egen dist_carhhd = sum(dist_car) //total distance travelled by car in household per day (summing)
replace dist_carhhd = . if FactorH_odin == .

bysort rinpersoonhkw: egen dist_carpphhd = sum(dist_carpp) //total distance travelled by car per passenger in household per day (summing)
replace dist_carpphhd = . if FactorH_odin == .

bysort rinpersoonhkw: egen dist_transithhd = sum(dist_transit) //total distance travelled by transit per day in household
replace dist_transithhd = . if FactorH_odin == .

bysort rinpersoonhkw: egen dist_walkhhd = sum(dist_walk) //total distance travelld by walking per day in household
replace dist_walkhhd = . if FactorH_odin == .

bysort rinpersoonhkw: egen dist_cyclehhd = sum(dist_cycle) //total distance travelld by cycling per day in household
replace dist_cyclehhd = . if FactorH_odin == .

bysort rinpersoonhkw: egen car_triphhd = sum(car_trip) //number of car trips per day at household level
replace car_triphhd = . if FactorH_odin == .

bysort rinpersoonhkw: egen transit_triphhd = sum(transit_trip) //number of transit trips per day at household level
replace transit_triphhd = . if FactorH_odin == .

bysort rinpersoonhkw: egen walk_triphhd = sum(walk_trip) //number of walking trips per day at household level
replace walk_triphhd = . if FactorH_odin == .

bysort rinpersoonhkw: egen cycle_triphhd = sum(cycle_trip) //number of cycling trips per day at household level
replace cycle_triphhd = . if FactorH_odin == .

*
gen dist_carhhd_pd = dist_carhhd * FactorP_odin //this weight calculates daily mobility (total distance travelled per household per day, using weights)
gen dist_carpphhd_pd = dist_carpphhd * FactorP_odin //this weight calculates daily mobility (total distance travelled per household per day, using weights)
gen dist_transithhd_pd = dist_transithhd * FactorP_odin //this weight calculates daily mobility (total distance travelled per household per day, using weights)
gen dist_walkhhd_pd = dist_walkhhd * FactorP_odin //this weight calculates daily mobility (total distance travelled per household per day, using weights)
gen dist_cyclehhd_pd = dist_cyclehhd * FactorP_odin //this weight calculates daily mobility (total distance travelled per household per day, using weights)
*
gen car_triphhd_pd = car_triphhd * FactorP_odin //this weight calculates daily mobility (number of trips per household per day, using weights)
gen transit_triphhd_pd = transit_triphhd * FactorP_odin //this weight calculates daily mobility (number of trips per household per day, using weights)
gen walk_triphhd_pd = walk_triphhd * FactorP_odin //this weight calculates daily mobility (number of trips per household per day, using weights)
gen cycle_triphhd_pd = cycle_triphhd * FactorP_odin //this weight calculates daily mobility (number of trips per household per day, using weights)
***

gen dist_carhhd_py = dist_carhhd * FactorV_odin //this weight calculates annual mobility (total distance travelled per year, using weights)
gen dist_carpphhd_py = dist_carpphhd * FactorV_odin //this weight calculates annual mobility (total distance travelled per year, using weights)
gen dist_transithhd_py = dist_transithhd * FactorV_odin //this weight calculates annual mobility (total distance travelled per year, using weights)
gen dist_walkhhd_py = dist_walkhhd * FactorV_odin //this weight calculates annual mobility (total distance travelled per year, using weights)
gen dist_cyclehhd_py = dist_cyclehhd * FactorV_odin //this weight calculates annual mobility (total distance travelled per year, using weights)
*
gen car_triphhd_py = car_triphhd * FactorV_odin //this weight calculates daily mobility (number of trips per household per year, using weights)
gen transit_triphhd_py = transit_triphhd * FactorV_odin //this weight calculates daily mobility (number of trips per household per year, using weights)
gen walk_triphhd_py = walk_triphhd * FactorV_odin //this weight calculates daily mobility (number of trips per household per year, using weights)
gen cycle_triphhd_py = cycle_triphhd * FactorV_odin //this weight calculates daily mobility (number of trips per household per year, using weights)





save "H:\Cody Hochstenbach\social ecological\person master 2019.dta", replace //this master file contains all dwellings and all available information
**manually delete the other saved files from folder

*clear all
*use "H:\Cody Hochstenbach\social ecological\person master 2019.dta"
*sort rinpersoons rinpersoon
*******************************************************************************************************************************
*******************************************************************************************************************************
*******************************************************************************************************************************
*******************************************************************************************************************************
*******************************************************************************************************************************
*******************************************************************************************************************************
*******************************************************************************************************************************
*******************************************************************************************************************************
**from here analysis, joining the two datasets (housing x household)

clear all 
use "H:\Cody Hochstenbach\social ecological\person master 2019.dta",
tab hhd_head
keep if hhd_head==1 //only household heads
tab hhd_head
keep if age2019>=18 & age2019<65 //only working age population for this version, here operationalized as 18-65 year olds
keep if p_hinceq2019>0 & p_hinceq2019<=100 //only households with assigned income
tab hhd_head
tab p_hinceq2019


*some dwellings hold multiple households
*this is a problem for our analysis
*first identify households that share an address (or, rinobject)
sort rinobjectnummer
quietly by rinobjectnummer: gen duplicate = cond(_N==1,0,_n)
tab duplicate if duplicate<10 
*most are 1 household per address (94.4%) but also some have 2 or 3 households on an address (2 x 2.2%)

*alternative check
bysort rinobjectnummer: egen n_hhds = sum(hhd_head) //number of households on given address
tab n_hhds 
*there can be multiple explanations:
*1) households actually sharing an address
*2) registration issues: especially older buildings are sometimes registered as 1 address even if they are multiple apartments
*3) registration issues 2: a household is incorrectly labelled as 2 or more households
*additional checks show sharing households to be relatively low income and mostly 1-person households

*now decided what to do with duplicates, below goes into different options


****************************************************************************************************************************************************
*OPTION 1
*this option is the cleanest and simply removes all duplicates
tab n_hhds if n_hhds<10
tab duplicate if duplicate<10

keep if n_hhds==1
tab hhd_head
sort soortobjectnummer rinobjectnummer

recast str32 rinobjectnummer

save "H:\Cody Hochstenbach\social ecological\household master 2019.dta", replace //this master file contains all household information

****************************************************************************************************************************************************
*OPTION 2
*this option keeps households that live on a dwelling individually (1) as well as those that live with 2 or 3 households (including themselves)
*this option is not as clean, but more complete data
*this option will in the next step assign one household to each address (i.e. removing the other sharing households, picking one representative)

*keep if n_hhds==1|n_hhds==2|n_hhds==3 //this rule keeps households 
*save "H:\Cody Hochstenbach\social ecological\household master.dta", replace //this master file contains all household information

****************************************************************************************************************************************************
*OPTION 3
*this option keeps households that live on a dwelling individually (1) as well as those that live with 2 or 3 households (including themselves)
*it then collapses households into an address, meaning that sharing households will be merged (summing their income, members)
*treating them in fact as a single households
*this option is not as clean, but more complete data

*keep if n_hhds==1|n_hhds==2|n_hhds==3 //this rule keeps households living individualy or sharing with 2 or 3 (all others are discarded)

*collapse to address, treating multiple households sharing one address as 1 household
*collapse ///
*(sum) hinc2021 hinceq2021 n_hhdmem2021 n_adultmem2021 n_childmem2021 ///
*(mean) hinceq2021_mean=hinceq2021 ///
*(first) n_hhds ///
*, by(soortobjectnummer rinobjectnummer)

*save "H:\Cody Hochstenbach\social ecological\household master.dta", replace //this master file contains all household information

****************************************************************************************************************************************************

clear all 
use "H:\Cody Hochstenbach\social ecological\housing master 2019.dta"
joinby soortobjectnummer rinobjectnummer using "H:\Cody Hochstenbach\social ecological\household master 2019.dta", unmatched(master)
drop _merge

drop p_hinc2019 p_hinceq2019
xtile p_hinc2019 = hinc2019 if selected_house==1, nq(100) //create income deciles from gross household income
tab p_hinc2019
xtile p_hinceq2019 = hinceq2019 if selected_house==1, nq(100) //create income deciles from equivalized household income
tab p_hinceq2019

gen inc_class2019 = .
replace inc_class2019 = 1 if p_hinceq2019>=1 & p_hinceq2019<=50 //poorest 50%
replace inc_class2019 = 2 if p_hinceq2019>=51 & p_hinceq2019<=90 //next 40%
replace inc_class2019 = 3 if p_hinceq2019>=91 & p_hinceq2019<=99 //next 9%
replace inc_class2019 = 4 if p_hinceq2019==100 //top 1%

xtile d_hinceq2019 = hinceq2019 if selected_house==1, nq(10) //create income deciles from equivalized household income
tab d_hinceq2019


tab tenure2019
tab heatpump_dummy2019
tab tenure2019 heatpump_dummy2019
tab typology4_2019 
tab typology4_2019 heatpump_dummy2019
summ distance_train2019 distance_depstore2019 distance_supermarket2019 distance_middleschool2019

tab d_hinceq2019 inc_decile_odin

gen n_hhd = 1 //var for counting hhds

gen dens1 = 1 if density2019==1 //highly urban
gen dens2 = 1 if density2019==2 //urban
gen dens3 = 1 if density2019==3 //moderate urban (dense suburban)
gen dens4 = 1 if density2019==4 //low urban (suburban)
gen dens5 = 1 if density2019==5 //not urban (rural)

gen size2019pp = size2019_w1/n_hhdmem2019 // size per persons (square meters divided by members)
winsor2 size2019pp, suffix(_w1) cuts(1 99) //also winsorize this

xtile q_distance_train2019 = distance_train2019 if selected_house==1, nq(5) //quintile groups of distance to train station
xtile q_distance_depstore2019 = distance_depstore2019 if selected_house==1, nq(5) //quintile groups of distance to department store
xtile q_distance_supermarket2019 = distance_supermarket2019 if selected_house==1, nq(5) //quintile groups of distance to supermarket
xtile q_distance_middleschool2019 = distance_middleschool2019 if selected_house==1, nq(5) //quintile groups of distance to middle school


save "H:\Cody Hochstenbach\social ecological\housing x household master 2019.dta", replace //this master file contains all dwellings and all household information





*****************************************************************************************************************************************************************************
*****************************************************************************************************************************************************************************
*****************************************************************************************************************************************************************************
*now collapse data to typologies
*see seperate do-file for alternative collapses

***collapse data by income deciles, building typology, construction year, urbanity and distance to train
clear all 
use "H:\Cody Hochstenbach\social ecological\housing x household master 2019.dta"

***choose here whether to use gross or equivalized income deciles!!
gen inc_decile = d_hinceq2019 //using this one means using equivalized
*gen inc_decile = d_hinc2019 //using this one means using gross

***choose which construction year categorization to use
*gen const_cat2019 = const_cat7 //7-fold typology
gen const_cat2019 = const_cat6 //6-fold typology

keep if selected_house==1 & inc_class2019>=1 & inc_class2019<=10 & q_distance_train2019>=1 & q_distance_train2019<=5

summ size2019_w1 size2019pp size2019pp_w1 if inc_class2019==1
summ size2019_w1 size2019pp size2019pp_w1 if inc_class2019==2
summ size2019_w1 size2019pp size2019pp_w1 if inc_class2019==3
summ size2019_w1 size2019pp size2019pp_w1 if inc_class2019==4

** these checks show that higher income groups on average live larger; the bottom decile is the odd one out, with more square meters than deciles 2-4. Much of this "effect" already disappears when limiting the analyses to those aged 25+ but part of it also because this decile is a mixed bag of people (e.g. self employed who are actually quite rich, those that manipulate their incomes etc)
**when removing duplicates (i.e. dwellings with multiple households), this issue disappears

tab inc_class2019 typology2019, row nof
tab inc_class2019 const_cat2019, row nof
tab inc_class2019 density2019, row nof
*these checks show expected associations
 
 
rename solar_dummy2019 n_solar2019
rename heatpump_dummy2019 n_heatpump2019
rename cityheating_dummy2019 n_cityheating2019

collapse ///
(mean) size2019_w1 size2019pp_w1 addresses2019 ///
       distance_train2019 distance_supermarket2019 distance_depstore2019 distance_middleschool2019 ///
	   electricity2019 netelectricity2019 gas2019 solarcapacity2019 warmteschatting_SW ///
(sd) size2019_sd=size2019_w1 size2019pp_sd=size2019pp_w1 addresses2019_sd=addresses2019 ///
	 distance_train2019_sd=distance_train2019 distance_supermarket2019_sd=distance_supermarket2019 /// 
	 distance_depstore2019_sd=distance_depstore2019 distance_middleschool2019_sd=distance_middleschool2019 ///
	 electricity2019_sd=electricity2019 netelectricity2019_sd=netelectricity2019 gas2019_sd=gas2019 ///
	 solarcapacity2019_sd=solarcapacity2019 warmteschatting_SW_sd=warmteschatting_SW ///
(median) size2019_med=size2019_w1 size2019pp_med=size2019pp_w1 addresses2019_med=addresses2019 ///
	 distance_train2019_med=distance_train2019 distance_supermarket2019_med=distance_supermarket2019 ///
	 distance_depstore2019_med=distance_depstore2019 distance_middleschool2019_med=distance_middleschool2019 ///
	 electricity2019_med=electricity2019 netelectricity2019_med=netelectricity2019 gas2019_med=gas2019 ///
	 solarcapacity2019_med=solarcapacity2019 warmteschatting_SW_med=warmteschatting_SW ///	 
(sum) n_hhd n_hhdmem2019 n_adultmem2019 n_childmem2019 n_solar2019 n_heatpump2019 n_cityheating2019 ///
, by(inc_class2019 typology4_2019 const_cat2019 density2019 q_distance_train2019)
*max number of rows is 10 incomes x 4 typologies x 6 construction periods x 5 densities x 5 train distances
*4x4x6x5x5=2400
total n_hhd n_hhdmem2019 
tab inc_class2019

gen inc_lab = "poorest 1-50%" if inc_class2019==1
replace inc_lab = "51-90%" if inc_class2019==2
replace inc_lab = "91-99%" if inc_class2019==3
replace inc_lab = "richest 1%" if inc_class2019==4

gen typology_lab = "detached (vrijstaand)" if typology4_2019==1
replace typology_lab = "semi-detached (2-1 kap) / corner (hoek)" if typology4_2019==2
replace typology_lab = "row house (tussenwoning)" if typology4_2019==3
replace typology_lab = "multiple fam (meergezins)" if typology4_2019==4

gen const_lab = "pre 1945" if const_cat2019==1
replace const_lab = "1946-1964" if const_cat2019==2
replace const_lab = "1965-1974" if const_cat2019==3
replace const_lab = "1975-1991" if const_cat2019==4
replace const_lab = "1992-2005" if const_cat2019==5
replace const_lab = "2006-2022" if const_cat2019==6

gen density_lab = "very urban" if density2019==1
replace density_lab = "urban" if density2019==2
replace density_lab = "high suburban" if density2019==3
replace density_lab = "low suburban" if density2019==4
replace density_lab = "rural" if density2019==5

gen distance_train_lab = "nearest quintile" if q_distance_train2019==1
replace distance_train_lab = "2nd quintile" if q_distance_train2019==2
replace distance_train_lab = "3nd quintile" if q_distance_train2019==3
replace distance_train_lab = "4nd quintile" if q_distance_train2019==4
replace distance_train_lab = "furthest quintile" if q_distance_train2019==5


order inc_lab typology_lab const_lab density_lab distance_train_lab inc_class2019 typology4_2019 const_cat2019 density2019 q_distance_train2019 size2019_w1 size2019_sd size2019_med size2019pp_w1 size2019pp_sd size2019pp_med addresses2019 addresses2019_sd addresses2019_med n_hhd n_hhdmem2019 n_adultmem2019 n_childmem2019 distance_train2019 distance_train2019_sd distance_train2019_med distance_depstore2019 distance_depstore2019_sd distance_depstore2019_med distance_supermarket2019 distance_supermarket2019_sd distance_supermarket2019_med  distance_middleschool2019 distance_middleschool2019_sd distance_middleschool2019_med electricity2019 electricity2019_sd electricity2019_med netelectricity2019 netelectricity2019_sd netelectricity2019_med gas2019 gas2019_sd gas2019_med solarcapacity2019 solarcapacity2019_sd solarcapacity2019_med warmteschatting_SW warmteschatting_SW_sd warmteschatting_SW_med n_solar2019 n_heatpump2019 n_cityheating2019


*remove observartions where N<10 for privacy
replace n_hhd = . if n_hhd<10
replace n_hhdmem2019 = . if n_hhdmem2019<10
replace n_adultmem2019 = . if n_adultmem2019<10
replace n_childmem2019 = . if n_childmem2019<10
replace n_solar2019 = . if n_solar2019<10
replace n_heatpump2019 = . if n_heatpump2019<10
replace n_cityheating2019 = . if n_cityheating2019<10

*round all other observations to 5 for privacy
replace n_hhd = round(n_hhd, 5)
replace n_hhdmem2019 = round(n_hhdmem2019, 5)
replace n_adultmem2019 = round(n_adultmem2019, 5)
replace n_childmem2019 = round(n_childmem2019, 5)
replace n_solar2019 = round(n_solar2019, 5)
replace n_heatpump2019 = round(n_heatpump2019, 5)
replace n_cityheating2019 = round(n_cityheating2019, 5)

*in those rows where the number of household observations is less than 10, we need to set all other values to missing as well 
recode size2019_w1 size2019_sd size2019_med size2019pp_w1 size2019pp_sd size2019pp_med addresses2019 addresses2019_sd addresses2019_med n_hhd n_hhdmem2019 n_adultmem2019 n_childmem2019 distance_train2019 distance_train2019_sd distance_train2019_med distance_depstore2019 distance_depstore2019_sd distance_depstore2019_med distance_supermarket2019 distance_supermarket2019_sd distance_supermarket2019_med  distance_middleschool2019 distance_middleschool2019_sd distance_middleschool2019_med electricity2019 electricity2019_sd electricity2019_med netelectricity2019 netelectricity2019_sd netelectricity2019_med gas2019 gas2019_sd gas2019_med solarcapacity2019 solarcapacity2019_sd solarcapacity2019_med warmteschatting_SW warmteschatting_SW_sd warmteschatting_SW_med n_solar2019 n_heatpump2019 n_cityheating2019 (*=.) if n_hhd==.

gen mean_hhd = n_hhdmem2019/n_hhd //calculate mean household size (after rounding for privacy reasons)
gen mean_adult = n_adultmem2019/n_hhd //mean adult members
gen mean_child = n_childmem2019/n_hhd //mean child members

tab inc_class2019 if n_hhd==. //check number of rows with insufficient cases for privacy reasons

save "H:\Cody Hochstenbach\social ecological\income typology construction density distance privacy 2019_age1864 incclass.dta", replace //aggregate data
export excel "H:\Cody Hochstenbach\social ecological\income typology construction density distance privacy 2019_age1864 incclass.xlsx", firstrow(var) replace //export to excel for output

*****************************************************************************************************************************************************************************
*****************************************************************************************************************************************************************************
*****************************************************************************************************************************************************************************
*now collapse data to typologies using ODIN survey data
*the survey data need to be weighted, therefore seperate collapse

***collapse data by income deciles, building typology and construction year
clear all 
use "H:\Cody Hochstenbach\social ecological\housing x household master 2019.dta"

***choose here whether to use gross or equivalized income deciles!!

***choose which construction year categorization to use
*gen const_cat2019 = const_cat7 //7-fold typology
gen const_cat2019 = const_cat6 //6-fold typology

*only keep cases with no missing info
*this also selects household heads who have been assigned an income
keep if selected_house==1 & inc_decile>=1 & inc_decile<=10
keep if q_distance_train2019>=1 & q_distance_train2019<=5

*only keep ODIN survey cases
keep if FactorH_odin!=.

summ dist_carhhd car_triphhd

***run some checks
tab n_carshhd inc_class2019 [aweight=FactorP_odin], col nof //clear correlation income and car ownership, as expected
tab n_carshhd density [aweight=FactorP_odin], col nof //clear correlation density and car ownership, as expected
tab n_carshhd typology4_2019 [aweight=FactorP_odin], col nof //clear correlation housing typology and car ownership, as expected, likely structured by income/urbanity

summ dist_carhhd dist_carpphhd dist_transithhd dist_walkhhd dist_cyclehhd if inc_class2019==1 [aweight=FactorP_odin]
summ dist_carhhd dist_carpphhd dist_transithhd dist_walkhhd dist_cyclehhd if inc_class2019==2 [aweight=FactorP_odin]
summ dist_carhhd dist_carpphhd dist_transithhd dist_walkhhd dist_cyclehhd if inc_class2019==3 [aweight=FactorP_odin]
summ dist_carhhd dist_carpphhd dist_transithhd dist_walkhhd dist_cyclehhd if inc_class2019==4 [aweight=FactorP_odin]


rename n_hhd n_hhd_uw
gen n_hhd = n_hhd_uw * FactorH_odin
total n_hhd

total car_triphhd_pd dist_carhhd_pd

*now the data canbe collapsed by categories
collapse ///
(sum) n_hhd_uw n_hhd car_trips=car_triphhd_pd transit_trips=transit_triphhd_pd walk_trips = walk_triphhd_pd cycle_trips=cycle_triphhd_pd ///
car_hhd=n_carshhd dist_car=dist_carhhd_pd dist_carpp=dist_carpphhd_pd dist_transit=dist_transithhd_pd dist_walk=dist_walkhhd_pd dist_cycle=dist_cyclehhd_pd ///
car_trips_py=car_triphhd_py transit_trips_py=transit_triphhd_py walk_trips_py = walk_triphhd_py cycle_trips_py=cycle_triphhd_py ///
dist_car_py=dist_carhhd_py dist_carpp_py=dist_carpphhd_py dist_transit_py=dist_transithhd_py dist_walk_py=dist_walkhhd_py dist_cycle_py=dist_cyclehhd_py ///
, by(inc_class2019 density2019 q_distance_train2019)
*max number of rows is 10 incomes x 5 densities x 5 train distances
*4x5x5=100 rows
*py = per year mobility data; without indication it is per day
total n_hhd
total n_hhd if inc_class2019==1
total n_hhd if inc_class2019==4
total car_trips dist_car


gen inc_lab = "poorest 1-50%" if inc_class2019==1
replace inc_lab = "51-90%" if inc_class2019==2
replace inc_lab = "91-99%" if inc_class2019==3
replace inc_lab = "richest 1%" if inc_class2019==4



gen density_lab = "very urban" if density2019==1
replace density_lab = "urban" if density2019==2
replace density_lab = "high suburban" if density2019==3
replace density_lab = "low suburban" if density2019==4
replace density_lab = "rural" if density2019==5

gen distance_train_lab = "nearest quintile" if q_distance_train2019==1
replace distance_train_lab = "2nd quintile" if q_distance_train2019==2
replace distance_train_lab = "3nd quintile" if q_distance_train2019==3
replace distance_train_lab = "4nd quintile" if q_distance_train2019==4
replace distance_train_lab = "furthest quintile" if q_distance_train2019==5

*only show one decimal place
format car_hhd %4.1f
format dist_car %4.1f
format dist_carpp %4.1f
format dist_transit %4.1f
format dist_walk %4.1f
format dist_cycle %4.1f
format dist_car_py %4.1f
format dist_carpp_py %4.1f
format dist_transit_py %4.1f
format dist_walk_py %4.1f
format dist_cycle_py %4.1f

order inc_lab density_lab distance_train_lab inc_class2019 density2019 q_distance_train2019 n_hhd_uw n_hhd car_hhd car_trips transit_trips walk_trips cycle_trips dist_car dist_carpp dist_transit dist_walk dist_cycle car_trips_py transit_trips_py walk_trips_py cycle_trips_py dist_car_py dist_carpp_py dist_transit_py dist_walk_py dist_cycle_py

*remove observartions where N<10 for privacy
replace n_hhd_uw=. if n_hhd_uw<10
recode n_hhd car_hhd car_trips transit_trips walk_trips cycle_trips dist_car dist_carpp dist_transit dist_walk dist_cycle car_trips_py transit_trips_py walk_trips_py cycle_trips_py dist_car_py dist_carpp_py dist_transit_py dist_walk_py dist_cycle_py (*=.) if n_hhd_uw==.


*anonymize where variable specific N<10
replace n_hhd_uw = . if(n_hhd_uw<10)
replace n_hhd = . if(n_hhd<10)
replace car_trips= . if(car_trips<10)
replace transit_trips= . if(transit_trips<10)
replace walk_trips= . if(walk_trips<10)
replace cycle_trips= . if(cycle_trips<10)
replace car_trips_py= . if(car_trips_py<10)
replace transit_trips_py= . if(transit_trips_py<10)
replace walk_trips_py= . if(walk_trips_py<10)
replace cycle_trips_py= . if(cycle_trips_py<10)

replace dist_car=. if(dist_car<10)
replace dist_carpp=. if(dist_carpp<10)
replace dist_transit=. if(dist_transit<10)
replace dist_walk=. if(dist_walk<10)
replace dist_cycle=. if(dist_cycle<10)
replace dist_car_py=. if(dist_car_py<10)
replace dist_carpp_py=. if(dist_carpp_py<10)
replace dist_transit_py=. if(dist_transit_py<10)
replace dist_walk_py=. if(dist_walk_py<10)
replace dist_cycle_py=. if(dist_cycle_py<10)

*round counts
replace n_hhd_uw = round(n_hhd_uw, 5)
replace n_hhd = round(n_hhd, 5)
replace car_trips= round(car_trips, 5)
replace transit_trips= round(transit_trips, 5)
replace walk_trips= round(walk_trips, 5)
replace cycle_trips= round(cycle_trips, 5)
replace car_trips_py= round(car_trips_py, 5)
replace transit_trips_py= round(transit_trips_py, 5)
replace walk_trips_py= round(walk_trips_py, 5)
replace cycle_trips_py= round(cycle_trips_py, 5)
*all other vars are mean distances (based on N>=10 cases)

tab inc_class2019 if n_hhd==.

save "H:\Cody Hochstenbach\social ecological\income density distance privacy odin 2019_age1864 incclass.dta", replace //aggregate data
export excel "H:\Cody Hochstenbach\social ecological\income density distance privacy odin 2019_age1864 incclass.xlsx", firstrow(var) replace //export to excel for output

*****************************************************************************************************************************************************************************
*****************