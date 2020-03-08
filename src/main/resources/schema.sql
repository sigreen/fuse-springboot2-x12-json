DROP TABLE IF EXISTS transaction_details; 

CREATE TABLE transaction_details (
  CommonAccessReference varchar(60) NOT NULL,
  MessageFunction varchar(3) NOT NULL,
  RecordLocator varchar(6) NOT NULL,
  TravellerSurname varchar(255) NOT NULL,
  FlightNumber varchar(6),
  DepartureAirportCode varchar(3),
  DepartureDateTime varchar(60),
  ArrivalAirportCode varchar(3),
  ArrivalDateTime varchar(60),
  SpecialRequirementsType varchar(4),
  SpecialRequirementsDetails varchar(255)
);