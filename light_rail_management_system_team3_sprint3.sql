-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 06, 2017 at 05:17 AM
-- Server version: 10.1.26-MariaDB
-- PHP Version: 7.1.8

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `light_rail_management_system_team3_sprint3`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_delay_alert` (IN `delay_time` INT(11), IN `train_idd` INT(11), IN `alert_messagee` VARCHAR(256))  BEGIN
declare x integer;
set x = delay_time * 100;
update schedule set actual_time = actual_time + x , alert_message = alert_messagee where train_id=train_idd and station_status = 'active' and train_status='active' and CURRENT_TIMESTAMP < actual_time;
End$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `book_ticket` (IN `schedule_id` INT(11), IN `ticket_type` VARCHAR(255))  BEGIN
INSERT INTO passenger(
	booking_time,
	schedule_id,
	ticket_id,
	ticket_status,
	ticket_type,ending_time)values(NOW(), schedule_id, NULL, 'valid', ticket_type, getEndingTime(NOW(), ticket_type));
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `call_route` (IN `route_namee` VARCHAR(255))  BEGIN
	SELECT
    	route_name,
    	station_name,
    	train_id,
    	actual_time,
        `Time left`,
    	schedule_number
	FROM
    	passenger_route_station
	WHERE
    	route_name = route_namee
        order by `Time left`;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `call_station` (IN `station_namee` VARCHAR(255))  BEGIN
select route_name, station_name, train_id, actual_time, `Time left`, schedule_number from passenger_route_station where station_name = station_namee
order by `Time left`;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `schedule_delay` (IN `delay_time` INT, IN `schedule_number` INT, IN `alert_messagee` VARCHAR(255))  begin
declare x integer;
set x = delay_time * 100;
update schedule set actual_time = actual_time + x, alert_message = alert_messagee where id = schedule_number and station_status = 'active' and train_status='active' and CURRENT_TIMESTAMP < actual_time;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `train_io` (IN `station_namee` VARCHAR(255))  BEGIN
declare route_namee varchar (255);
select distinct route_name from passenger_route_station where station_name=station_namee into route_namee;
select train_id, `Time left`, station_name, route_name 
FROM
passenger_route_station 
WHERE
route_name = route_namee and station_name<>station_namee
order by `Time left`;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `f_display_duration` (`p_train_id` INT, `p_station_id` INT, `p_schedule_id` INT) RETURNS TIME begin
declare duration time;
declare p_actual_time time;

select actual_time into p_actual_time from schedule where train_id=p_train_id and station_id=p_station_id and id=p_schedule_id;
set duration = ABS(SUBTIME(CURRENT_TIME(), p_actual_time));
return (duration);
end$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getEndingTime` (`booking_time` DATETIME, `ticket_type` VARCHAR(256)) RETURNS DATETIME BEGIN 
DECLARE x TIMESTAMP;
DECLARE y TIMESTAMP;

SET x = booking_time;

if(ticket_type = 'monthly') then
		SET y = DATE_ADD(x, INTERVAL 720 HOUR);
elseif(ticket_type = 'weekly') then
		SET y = DATE_ADD(x, INTERVAL 168 HOUR);
elseif(ticket_type = 'one-day') then
		SET y = DATE_ADD(x, INTERVAL 24 HOUR);
elseif(ticket_type = 'two-hour') then
		SET y = DATE_ADD(x, INTERVAL 2 HOUR);
	END IF;

RETURN (y);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `first_name` varchar(256) DEFAULT NULL,
  `last_name` varchar(256) DEFAULT NULL,
  `email_id` varchar(256) NOT NULL,
  `password` varchar(256) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`first_name`, `last_name`, `email_id`, `password`) VALUES
('Thomas', 'McEniry', 'tmceniry@lrms.com', 'zaq1cde3');

-- --------------------------------------------------------

--
-- Stand-in structure for view `admin_train_delay`
-- (See below for the actual view)
--
CREATE TABLE `admin_train_delay` (
`estimated_time` time
,`actual_time` time
,`train_id` int(11)
,`alert_message` varchar(256)
);

-- --------------------------------------------------------

--
-- Table structure for table `passenger`
--

CREATE TABLE `passenger` (
  `ticket_id` int(11) NOT NULL,
  `ticket_type` varchar(256) NOT NULL,
  `booking_time` datetime NOT NULL,
  `ending_time` datetime DEFAULT NULL,
  `ticket_status` varchar(256) NOT NULL,
  `schedule_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `passenger`
--

INSERT INTO `passenger` (`ticket_id`, `ticket_type`, `booking_time`, `ending_time`, `ticket_status`, `schedule_id`) VALUES
(12, 'two-hour', '2017-12-03 01:45:31', '2017-12-03 01:45:31', 'inactive', 1),
(13, 'two-hour', '2017-12-03 01:45:31', '2017-12-03 03:45:31', 'inactive', 1),
(14, 'two-hour', '2017-12-03 01:45:31', '2017-12-03 03:45:31', 'inactive', 1),
(15, 'one-day', '2017-12-03 01:46:33', '2017-12-03 01:46:33', 'inactive', 2),
(16, 'one-day', '2017-12-03 01:46:33', '2017-12-04 01:46:33', 'inactive', 3),
(17, 'one-day', '2017-12-03 01:46:33', '2017-12-04 01:46:33', 'inactive', 4),
(18, 'one-day', '2017-12-03 01:46:33', '2017-12-03 02:01:55', 'inactive', 5),
(19, 'weekly', '2017-12-03 01:46:33', '2017-12-05 01:46:33', 'inactive', 6),
(20, 'weekly', '2017-12-03 01:46:33', '2017-12-10 01:46:33', 'valid', 7),
(21, 'monthly', '2017-12-03 01:46:33', '2018-01-02 01:46:33', 'valid', 8),
(22, 'monthly', '2017-12-03 01:46:33', '2017-12-05 01:46:33', 'inactive', 9),
(23, 'two-hour', '2017-12-05 19:53:38', '2017-12-05 21:53:38', 'inactive', 1);

-- --------------------------------------------------------

--
-- Stand-in structure for view `passenger_route_station`
-- (See below for the actual view)
--
CREATE TABLE `passenger_route_station` (
`route_name` varchar(256)
,`station_name` varchar(256)
,`train_id` int(11)
,`actual_time` time
,`schedule_number` int(11)
,`Time left` time
);

-- --------------------------------------------------------

--
-- Table structure for table `route`
--

CREATE TABLE `route` (
  `name` varchar(256) NOT NULL,
  `Duration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `route`
--

INSERT INTO `route` (`name`, `Duration`) VALUES
('blue', 55),
('green', 35),
('red', 45);

-- --------------------------------------------------------

--
-- Table structure for table `schedule`
--

CREATE TABLE `schedule` (
  `id` int(11) NOT NULL,
  `estimated_time` time NOT NULL,
  `actual_time` time NOT NULL,
  `train_status` varchar(256) NOT NULL,
  `station_status` varchar(256) NOT NULL,
  `station_id` int(11) NOT NULL,
  `train_id` int(11) NOT NULL,
  `alert_message` varchar(256) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `schedule`
--

INSERT INTO `schedule` (`id`, `estimated_time`, `actual_time`, `train_status`, `station_status`, `station_id`, `train_id`, `alert_message`) VALUES
(1, '06:00:00', '06:00:00', 'Inactive', 'Inactive', 1, 111, NULL),
(2, '06:10:00', '06:10:00', 'Inactive', 'Inactive', 2, 111, NULL),
(3, '06:20:00', '06:20:00', 'Inactive', 'Inactive', 3, 111, NULL),
(4, '06:35:00', '06:35:00', 'Inactive', 'Inactive', 4, 111, NULL),
(5, '06:45:00', '06:45:00', 'Inactive', 'Inactive', 5, 111, NULL),
(6, '06:55:00', '06:55:00', 'Inactive', 'Inactive', 4, 111, NULL),
(7, '07:10:00', '07:10:00', 'Inactive', 'Inactive', 3, 111, NULL),
(8, '07:20:00', '07:20:00', 'Inactive', 'Inactive', 2, 111, NULL),
(9, '07:30:00', '07:30:00', 'Inactive', 'Inactive', 1, 111, NULL),
(10, '08:00:00', '08:00:00', 'Inactive', 'Inactive', 1, 111, NULL),
(11, '08:10:00', '08:10:00', 'Inactive', 'Inactive', 2, 111, NULL),
(12, '08:20:00', '08:20:00', 'Inactive', 'Inactive', 3, 111, NULL),
(13, '08:35:00', '08:35:00', 'Inactive', 'Inactive', 4, 111, NULL),
(14, '08:45:00', '08:45:00', 'Inactive', 'Inactive', 5, 111, NULL),
(15, '08:55:00', '08:55:00', 'Inactive', 'Inactive', 4, 111, NULL),
(16, '09:10:00', '09:10:00', 'Inactive', 'Inactive', 3, 111, NULL),
(17, '09:20:00', '09:20:00', 'Inactive', 'Inactive', 2, 111, NULL),
(18, '09:30:00', '09:30:00', 'Inactive', 'Inactive', 1, 111, NULL),
(19, '10:00:00', '10:00:00', 'Inactive', 'Inactive', 1, 111, NULL),
(20, '10:10:00', '10:10:00', 'Inactive', 'Inactive', 2, 111, NULL),
(21, '10:20:00', '10:20:00', 'Inactive', 'Inactive', 3, 111, NULL),
(22, '10:35:00', '10:35:00', 'Inactive', 'Inactive', 4, 111, NULL),
(23, '10:45:00', '10:45:00', 'Inactive', 'Inactive', 5, 111, NULL),
(24, '10:55:00', '10:55:00', 'Inactive', 'Inactive', 4, 111, NULL),
(25, '11:10:00', '11:10:00', 'Inactive', 'Inactive', 3, 111, NULL),
(26, '11:20:00', '11:20:00', 'Inactive', 'Inactive', 2, 111, NULL),
(27, '11:30:00', '11:30:00', 'Inactive', 'Inactive', 1, 111, NULL),
(28, '12:00:00', '12:00:00', 'Inactive', 'Inactive', 1, 111, NULL),
(29, '12:10:00', '12:10:00', 'Inactive', 'Inactive', 2, 111, NULL),
(30, '12:20:00', '12:20:00', 'Inactive', 'Inactive', 3, 111, NULL),
(31, '12:35:00', '12:35:00', 'Inactive', 'Inactive', 4, 111, NULL),
(32, '12:45:00', '12:45:00', 'Inactive', 'Inactive', 5, 111, NULL),
(33, '12:55:00', '12:55:00', 'Inactive', 'Inactive', 4, 111, NULL),
(34, '13:10:00', '13:10:00', 'Inactive', 'Inactive', 3, 111, NULL),
(35, '13:20:00', '13:20:00', 'Inactive', 'Inactive', 2, 111, NULL),
(36, '13:30:00', '13:30:00', 'Inactive', 'Inactive', 1, 111, NULL),
(37, '14:00:00', '14:00:00', 'Inactive', 'Inactive', 1, 111, NULL),
(38, '14:10:00', '14:10:00', 'Inactive', 'Inactive', 2, 111, NULL),
(39, '14:20:00', '14:20:00', 'Inactive', 'Inactive', 3, 111, NULL),
(40, '14:35:00', '14:35:00', 'Inactive', 'Inactive', 4, 111, NULL),
(41, '14:45:00', '14:45:00', 'Inactive', 'Inactive', 5, 111, NULL),
(42, '14:55:00', '14:55:00', 'Inactive', 'Inactive', 4, 111, NULL),
(43, '15:10:00', '15:10:00', 'Inactive', 'Inactive', 3, 111, NULL),
(44, '15:20:00', '15:20:00', 'Inactive', 'Inactive', 2, 111, NULL),
(45, '15:30:00', '15:30:00', 'Inactive', 'Inactive', 1, 111, NULL),
(46, '16:00:00', '16:00:00', 'Inactive', 'Inactive', 1, 111, NULL),
(47, '16:10:00', '16:10:00', 'Inactive', 'Inactive', 2, 111, NULL),
(48, '16:20:00', '16:20:00', 'Inactive', 'Inactive', 3, 111, NULL),
(49, '16:35:00', '16:35:00', 'Inactive', 'Inactive', 4, 111, NULL),
(50, '16:45:00', '16:45:00', 'Inactive', 'Inactive', 5, 111, NULL),
(51, '16:55:00', '16:55:00', 'Inactive', 'Inactive', 4, 111, NULL),
(52, '17:10:00', '17:10:00', 'Inactive', 'Inactive', 3, 111, NULL),
(53, '17:20:00', '17:20:00', 'Inactive', 'Inactive', 2, 111, NULL),
(54, '17:30:00', '17:30:00', 'Inactive', 'Inactive', 1, 111, NULL),
(55, '18:00:00', '18:00:00', 'Inactive', 'Inactive', 1, 111, NULL),
(56, '18:10:00', '18:10:00', 'Inactive', 'Inactive', 2, 111, NULL),
(57, '18:20:00', '18:20:00', 'Inactive', 'Inactive', 3, 111, NULL),
(58, '18:35:00', '18:35:00', 'Inactive', 'Inactive', 4, 111, NULL),
(59, '18:45:00', '18:45:00', 'Inactive', 'Inactive', 5, 111, NULL),
(60, '18:55:00', '18:55:00', 'Inactive', 'Inactive', 4, 111, NULL),
(61, '19:10:00', '19:10:00', 'Inactive', 'Inactive', 3, 111, NULL),
(62, '19:20:00', '19:20:00', 'Inactive', 'Inactive', 2, 111, NULL),
(63, '19:30:00', '19:30:00', 'Inactive', 'Inactive', 1, 111, NULL),
(64, '06:15:00', '06:15:00', 'Inactive', 'Inactive', 1, 222, NULL),
(65, '06:25:00', '06:25:00', 'Inactive', 'Inactive', 2, 222, NULL),
(66, '06:35:00', '06:35:00', 'Inactive', 'Inactive', 3, 222, NULL),
(67, '06:50:00', '06:50:00', 'Inactive', 'Inactive', 4, 222, NULL),
(68, '07:00:00', '07:00:00', 'Inactive', 'Inactive', 5, 222, NULL),
(69, '07:10:00', '07:10:00', 'Inactive', 'Inactive', 4, 222, NULL),
(70, '07:25:00', '07:25:00', 'Inactive', 'Inactive', 3, 222, NULL),
(71, '07:35:00', '07:35:00', 'Inactive', 'Inactive', 2, 222, NULL),
(72, '07:45:00', '07:45:00', 'Inactive', 'Inactive', 1, 222, NULL),
(73, '08:15:00', '08:15:00', 'Inactive', 'Inactive', 1, 222, NULL),
(74, '08:25:00', '08:25:00', 'Inactive', 'Inactive', 2, 222, NULL),
(75, '08:35:00', '08:35:00', 'Inactive', 'Inactive', 3, 222, NULL),
(76, '08:50:00', '08:50:00', 'Inactive', 'Inactive', 4, 222, NULL),
(77, '09:00:00', '09:00:00', 'Inactive', 'Inactive', 5, 222, NULL),
(78, '09:10:00', '09:10:00', 'Inactive', 'Inactive', 4, 222, NULL),
(79, '09:25:00', '09:25:00', 'Inactive', 'Inactive', 3, 222, NULL),
(80, '09:35:00', '09:35:00', 'Inactive', 'Inactive', 2, 222, NULL),
(81, '09:45:00', '09:45:00', 'Inactive', 'Inactive', 1, 222, NULL),
(82, '10:15:00', '10:15:00', 'Inactive', 'Inactive', 1, 222, NULL),
(83, '10:25:00', '10:25:00', 'Inactive', 'Inactive', 2, 222, NULL),
(84, '10:35:00', '10:35:00', 'Inactive', 'Inactive', 3, 222, NULL),
(85, '10:50:00', '10:50:00', 'Inactive', 'Inactive', 4, 222, NULL),
(86, '11:00:00', '11:00:00', 'Inactive', 'Inactive', 5, 222, NULL),
(87, '11:10:00', '11:10:00', 'Inactive', 'Inactive', 4, 222, NULL),
(88, '11:25:00', '11:25:00', 'Inactive', 'Inactive', 3, 222, NULL),
(89, '11:35:00', '11:35:00', 'Inactive', 'Inactive', 2, 222, NULL),
(90, '11:45:00', '11:45:00', 'Inactive', 'Inactive', 1, 222, NULL),
(91, '12:15:00', '12:15:00', 'Inactive', 'Inactive', 1, 222, NULL),
(92, '12:25:00', '12:25:00', 'Inactive', 'Inactive', 2, 222, NULL),
(93, '12:35:00', '12:35:00', 'Inactive', 'Inactive', 3, 222, NULL),
(94, '12:50:00', '12:50:00', 'Inactive', 'Inactive', 4, 222, NULL),
(95, '13:00:00', '13:00:00', 'Inactive', 'Inactive', 5, 222, NULL),
(96, '13:10:00', '13:10:00', 'Inactive', 'Inactive', 4, 222, NULL),
(97, '13:25:00', '13:25:00', 'Inactive', 'Inactive', 3, 222, NULL),
(98, '13:35:00', '13:35:00', 'Inactive', 'Inactive', 2, 222, NULL),
(99, '13:45:00', '13:45:00', 'Inactive', 'Inactive', 1, 222, NULL),
(100, '14:15:00', '14:15:00', 'Inactive', 'Inactive', 1, 222, NULL),
(101, '14:25:00', '14:25:00', 'Inactive', 'Inactive', 2, 222, NULL),
(102, '14:35:00', '14:35:00', 'Inactive', 'Inactive', 3, 222, NULL),
(103, '14:50:00', '14:50:00', 'Inactive', 'Inactive', 4, 222, NULL),
(104, '15:00:00', '15:00:00', 'Inactive', 'Inactive', 5, 222, NULL),
(105, '15:10:00', '15:10:00', 'Inactive', 'Inactive', 4, 222, NULL),
(106, '15:25:00', '15:25:00', 'Inactive', 'Inactive', 3, 222, NULL),
(107, '15:35:00', '15:35:00', 'Inactive', 'Inactive', 2, 222, NULL),
(108, '15:45:00', '15:45:00', 'Inactive', 'Inactive', 1, 222, NULL),
(109, '16:15:00', '16:15:00', 'Inactive', 'Inactive', 1, 222, NULL),
(110, '16:25:00', '16:25:00', 'Inactive', 'Inactive', 2, 222, NULL),
(111, '16:35:00', '16:35:00', 'Inactive', 'Inactive', 3, 222, NULL),
(112, '16:50:00', '16:50:00', 'Inactive', 'Inactive', 4, 222, NULL),
(113, '17:00:00', '17:00:00', 'Inactive', 'Inactive', 5, 222, NULL),
(114, '17:10:00', '17:10:00', 'Inactive', 'Inactive', 4, 222, NULL),
(115, '17:25:00', '17:25:00', 'Inactive', 'Inactive', 3, 222, NULL),
(116, '17:35:00', '17:35:00', 'Inactive', 'Inactive', 2, 222, NULL),
(117, '17:45:00', '17:45:00', 'Inactive', 'Inactive', 1, 222, NULL),
(118, '18:15:00', '18:15:00', 'Inactive', 'Inactive', 1, 222, NULL),
(119, '18:25:00', '18:25:00', 'Inactive', 'Inactive', 2, 222, NULL),
(120, '18:35:00', '18:35:00', 'Inactive', 'Inactive', 3, 222, NULL),
(121, '18:50:00', '18:50:00', 'Inactive', 'Inactive', 4, 222, NULL),
(122, '19:00:00', '19:00:00', 'Inactive', 'Inactive', 5, 222, NULL),
(123, '19:10:00', '19:10:00', 'Inactive', 'Inactive', 4, 222, NULL),
(124, '19:25:00', '19:25:00', 'Inactive', 'Inactive', 3, 222, NULL),
(125, '19:35:00', '19:35:00', 'Inactive', 'Inactive', 2, 222, NULL),
(126, '19:45:00', '19:45:00', 'Inactive', 'Inactive', 1, 222, NULL),
(127, '06:00:00', '06:00:00', 'Inactive', 'Inactive', 6, 333, NULL),
(128, '06:15:00', '06:15:00', 'Inactive', 'Inactive', 7, 333, NULL),
(129, '06:35:00', '06:35:00', 'Inactive', 'Inactive', 8, 333, NULL),
(130, '06:55:00', '06:55:00', 'Inactive', 'Inactive', 7, 333, NULL),
(131, '07:10:00', '07:10:00', 'Inactive', 'Inactive', 6, 333, NULL),
(132, '08:00:00', '08:00:00', 'Inactive', 'Inactive', 6, 333, NULL),
(133, '08:15:00', '08:15:00', 'Inactive', 'Inactive', 7, 333, NULL),
(134, '08:35:00', '08:35:00', 'Inactive', 'Inactive', 8, 333, NULL),
(135, '08:55:00', '08:55:00', 'Inactive', 'Inactive', 7, 333, NULL),
(136, '09:10:00', '09:10:00', 'Inactive', 'Inactive', 6, 333, NULL),
(137, '10:00:00', '10:00:00', 'Inactive', 'Inactive', 6, 333, NULL),
(138, '10:15:00', '10:15:00', 'Inactive', 'Inactive', 7, 333, NULL),
(139, '10:35:00', '10:35:00', 'Inactive', 'Inactive', 8, 333, NULL),
(140, '10:55:00', '10:55:00', 'Inactive', 'Inactive', 7, 333, NULL),
(141, '11:10:00', '11:10:00', 'Inactive', 'Inactive', 6, 333, NULL),
(142, '12:00:00', '12:00:00', 'Inactive', 'Inactive', 6, 333, NULL),
(143, '12:15:00', '12:15:00', 'Inactive', 'Inactive', 7, 333, NULL),
(144, '12:35:00', '12:35:00', 'Inactive', 'Inactive', 8, 333, NULL),
(145, '12:55:00', '12:55:00', 'Inactive', 'Inactive', 7, 333, NULL),
(146, '13:10:00', '13:10:00', 'Inactive', 'Inactive', 6, 333, NULL),
(147, '14:00:00', '14:00:00', 'Inactive', 'Inactive', 6, 333, NULL),
(148, '14:15:00', '14:15:00', 'Inactive', 'Inactive', 7, 333, NULL),
(149, '14:35:00', '14:35:00', 'Inactive', 'Inactive', 8, 333, NULL),
(150, '14:55:00', '14:55:00', 'Inactive', 'Inactive', 7, 333, NULL),
(151, '15:10:00', '15:10:00', 'Inactive', 'Inactive', 6, 333, NULL),
(152, '16:00:00', '16:00:00', 'Inactive', 'Inactive', 6, 333, NULL),
(153, '16:15:00', '16:15:00', 'Inactive', 'Inactive', 7, 333, NULL),
(154, '16:35:00', '16:35:00', 'Inactive', 'Inactive', 8, 333, NULL),
(155, '16:55:00', '16:55:00', 'Inactive', 'Inactive', 7, 333, NULL),
(156, '17:10:00', '17:10:00', 'Inactive', 'Inactive', 6, 333, NULL),
(157, '18:00:00', '18:00:00', 'Inactive', 'Inactive', 6, 333, NULL),
(158, '18:15:00', '18:15:00', 'Inactive', 'Inactive', 7, 333, NULL),
(159, '18:35:00', '18:35:00', 'Inactive', 'Inactive', 8, 333, NULL),
(160, '18:55:00', '18:55:00', 'Inactive', 'Inactive', 7, 333, NULL),
(161, '19:10:00', '19:10:00', 'Inactive', 'Inactive', 6, 333, NULL),
(162, '06:00:00', '06:00:00', 'Inactive', 'Inactive', 9, 444, NULL),
(163, '06:15:00', '06:15:00', 'Inactive', 'Inactive', 10, 444, NULL),
(164, '06:25:00', '06:25:00', 'Inactive', 'Inactive', 11, 444, NULL),
(165, '06:55:00', '06:55:00', 'Inactive', 'Inactive', 12, 444, NULL),
(166, '07:25:00', '07:25:00', 'Inactive', 'Inactive', 11, 444, NULL),
(167, '07:35:00', '07:35:00', 'Inactive', 'Inactive', 10, 444, NULL),
(168, '07:50:00', '07:50:00', 'Inactive', 'Inactive', 9, 444, NULL),
(169, '06:15:00', '06:15:00', 'Inactive', 'Inactive', 9, 555, NULL),
(170, '06:30:00', '06:30:00', 'Inactive', 'Inactive', 10, 555, NULL),
(171, '06:40:00', '06:40:00', 'Inactive', 'Inactive', 11, 555, NULL),
(172, '07:10:00', '07:10:00', 'Inactive', 'Inactive', 12, 555, NULL),
(173, '07:40:00', '07:40:00', 'Inactive', 'Inactive', 11, 555, NULL),
(174, '07:50:00', '07:50:00', 'Inactive', 'Inactive', 10, 555, NULL),
(175, '08:05:00', '08:05:00', 'Inactive', 'Inactive', 9, 555, NULL),
(176, '06:30:00', '06:30:00', 'Inactive', 'Inactive', 9, 666, NULL),
(177, '06:45:00', '06:45:00', 'Inactive', 'Inactive', 10, 666, NULL),
(178, '06:55:00', '06:55:00', 'Inactive', 'Inactive', 11, 666, NULL),
(179, '07:25:00', '07:25:00', 'Inactive', 'Inactive', 12, 666, NULL),
(180, '07:55:00', '07:55:00', 'Inactive', 'Inactive', 11, 666, NULL),
(181, '08:05:00', '08:05:00', 'Inactive', 'Inactive', 10, 666, NULL),
(182, '08:20:00', '08:20:00', 'Inactive', 'Inactive', 9, 666, NULL),
(183, '09:00:00', '09:00:00', 'Inactive', 'Inactive', 9, 444, NULL),
(184, '09:15:00', '09:15:00', 'Inactive', 'Inactive', 10, 444, NULL),
(185, '09:25:00', '09:25:00', 'Inactive', 'Inactive', 11, 444, NULL),
(186, '09:55:00', '09:55:00', 'Inactive', 'Inactive', 12, 444, NULL),
(187, '10:25:00', '10:25:00', 'Inactive', 'Inactive', 11, 444, NULL),
(188, '10:35:00', '10:35:00', 'Inactive', 'Inactive', 10, 444, NULL),
(189, '10:50:00', '10:50:00', 'Inactive', 'Inactive', 9, 444, NULL),
(190, '09:15:00', '09:15:00', 'Inactive', 'Inactive', 9, 555, NULL),
(191, '09:30:00', '09:30:00', 'Inactive', 'Inactive', 10, 555, NULL),
(192, '09:40:00', '09:40:00', 'Inactive', 'Inactive', 11, 555, NULL),
(193, '10:10:00', '10:10:00', 'Inactive', 'Inactive', 12, 555, NULL),
(194, '10:40:00', '10:40:00', 'Inactive', 'Inactive', 11, 555, NULL),
(195, '10:50:00', '10:50:00', 'Inactive', 'Inactive', 10, 555, NULL),
(196, '11:05:00', '11:05:00', 'Inactive', 'Inactive', 9, 555, NULL),
(197, '09:30:00', '09:30:00', 'Inactive', 'Inactive', 9, 666, NULL),
(198, '09:45:00', '09:45:00', 'Inactive', 'Inactive', 10, 666, NULL),
(199, '09:55:00', '09:55:00', 'Inactive', 'Inactive', 11, 666, NULL),
(200, '10:25:00', '10:25:00', 'Inactive', 'Inactive', 12, 666, NULL),
(201, '10:55:00', '10:55:00', 'Inactive', 'Inactive', 11, 666, NULL),
(202, '11:05:00', '11:05:00', 'Inactive', 'Inactive', 10, 666, NULL),
(203, '11:20:00', '11:20:00', 'Inactive', 'Inactive', 9, 666, NULL),
(204, '12:00:00', '12:00:00', 'Inactive', 'Inactive', 9, 444, NULL),
(205, '12:15:00', '12:15:00', 'Inactive', 'Inactive', 10, 444, NULL),
(206, '12:25:00', '12:25:00', 'Inactive', 'Inactive', 11, 444, NULL),
(207, '12:55:00', '12:55:00', 'Inactive', 'Inactive', 12, 444, NULL),
(208, '13:25:00', '13:25:00', 'Inactive', 'Inactive', 11, 444, NULL),
(209, '13:35:00', '13:35:00', 'Inactive', 'Inactive', 10, 444, NULL),
(210, '13:50:00', '13:50:00', 'Inactive', 'Inactive', 9, 444, NULL),
(211, '12:15:00', '12:15:00', 'Inactive', 'Inactive', 9, 555, NULL),
(212, '12:30:00', '12:30:00', 'Inactive', 'Inactive', 10, 555, NULL),
(213, '12:40:00', '12:40:00', 'Inactive', 'Inactive', 11, 555, NULL),
(214, '13:10:00', '13:10:00', 'Inactive', 'Inactive', 12, 555, NULL),
(215, '13:40:00', '13:40:00', 'Inactive', 'Inactive', 11, 555, NULL),
(216, '13:50:00', '13:50:00', 'Inactive', 'Inactive', 10, 555, NULL),
(217, '14:05:00', '14:05:00', 'Inactive', 'Inactive', 9, 555, NULL),
(218, '12:30:00', '12:30:00', 'Inactive', 'Inactive', 9, 666, NULL),
(219, '12:45:00', '12:45:00', 'Inactive', 'Inactive', 10, 666, NULL),
(220, '12:55:00', '12:55:00', 'Inactive', 'Inactive', 11, 666, NULL),
(221, '13:25:00', '13:25:00', 'Inactive', 'Inactive', 12, 666, NULL),
(222, '13:55:00', '13:55:00', 'Inactive', 'Inactive', 11, 666, NULL),
(223, '14:05:00', '14:05:00', 'Inactive', 'Inactive', 10, 666, NULL),
(224, '14:20:00', '14:20:00', 'Inactive', 'Inactive', 9, 666, NULL),
(225, '15:00:00', '15:00:00', 'Inactive', 'Inactive', 9, 444, NULL),
(226, '15:15:00', '15:15:00', 'Inactive', 'Inactive', 10, 444, NULL),
(227, '15:25:00', '15:25:00', 'Inactive', 'Inactive', 11, 444, NULL),
(228, '15:55:00', '15:55:00', 'Inactive', 'Inactive', 12, 444, NULL),
(229, '16:25:00', '16:25:00', 'Inactive', 'Inactive', 11, 444, NULL),
(230, '16:35:00', '16:35:00', 'Inactive', 'Inactive', 10, 444, NULL),
(231, '16:50:00', '16:50:00', 'Inactive', 'Inactive', 9, 444, NULL),
(232, '15:15:00', '15:15:00', 'Inactive', 'Inactive', 9, 555, NULL),
(233, '15:30:00', '15:30:00', 'Inactive', 'Inactive', 10, 555, NULL),
(234, '15:40:00', '15:40:00', 'Inactive', 'Inactive', 11, 555, NULL),
(235, '16:10:00', '16:10:00', 'Inactive', 'Inactive', 12, 555, NULL),
(236, '16:40:00', '16:40:00', 'Inactive', 'Inactive', 11, 555, NULL),
(237, '16:50:00', '16:50:00', 'Inactive', 'Inactive', 10, 555, NULL),
(238, '17:05:00', '17:05:00', 'Inactive', 'Inactive', 9, 555, NULL),
(239, '15:30:00', '15:30:00', 'Inactive', 'Inactive', 9, 666, NULL),
(240, '15:45:00', '15:45:00', 'Inactive', 'Inactive', 10, 666, NULL),
(241, '15:55:00', '15:55:00', 'Inactive', 'Inactive', 11, 666, NULL),
(242, '16:25:00', '16:25:00', 'Inactive', 'Inactive', 12, 666, NULL),
(243, '16:55:00', '16:55:00', 'Inactive', 'Inactive', 11, 666, NULL),
(244, '17:05:00', '17:05:00', 'Inactive', 'Inactive', 10, 666, NULL),
(245, '17:20:00', '17:20:00', 'Inactive', 'Inactive', 9, 666, NULL),
(246, '18:00:00', '18:00:00', 'Inactive', 'Inactive', 9, 444, NULL),
(247, '18:15:00', '18:15:00', 'Inactive', 'Inactive', 10, 444, NULL),
(248, '18:25:00', '18:25:00', 'Inactive', 'Inactive', 11, 444, NULL),
(249, '18:55:00', '18:55:00', 'Inactive', 'Inactive', 12, 444, NULL),
(250, '19:25:00', '19:25:00', 'Inactive', 'Inactive', 11, 444, NULL),
(251, '19:35:00', '19:35:00', 'Inactive', 'Inactive', 10, 444, NULL),
(252, '19:50:00', '19:50:00', 'Inactive', 'Inactive', 9, 444, NULL),
(253, '18:15:00', '18:15:00', 'Inactive', 'Inactive', 9, 555, NULL),
(254, '18:30:00', '18:30:00', 'Inactive', 'Inactive', 10, 555, NULL),
(255, '18:40:00', '18:40:00', 'Inactive', 'Inactive', 11, 555, NULL),
(256, '19:10:00', '19:10:00', 'Inactive', 'Inactive', 12, 555, NULL),
(257, '19:40:00', '19:40:00', 'Inactive', 'Inactive', 11, 555, NULL),
(258, '19:50:00', '19:50:00', 'Inactive', 'Inactive', 10, 555, NULL),
(259, '20:05:00', '20:05:00', 'Inactive', 'Inactive', 9, 555, NULL),
(260, '18:30:00', '18:30:00', 'Inactive', 'Inactive', 9, 666, NULL),
(261, '18:45:00', '18:45:00', 'Inactive', 'Inactive', 10, 666, NULL),
(262, '18:55:00', '18:55:00', 'Inactive', 'Inactive', 11, 666, NULL),
(263, '19:25:00', '19:25:00', 'Inactive', 'Inactive', 12, 666, NULL),
(264, '19:55:00', '19:55:00', 'Inactive', 'Inactive', 11, 666, NULL),
(265, '20:05:00', '20:05:00', 'Inactive', 'Inactive', 10, 666, NULL),
(266, '20:20:00', '20:20:00', 'Inactive', 'Inactive', 9, 666, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `station`
--

CREATE TABLE `station` (
  `id` int(11) NOT NULL,
  `name` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `station`
--

INSERT INTO `station` (`id`, `name`) VALUES
(12, '5th Street'),
(4, 'Archdale'),
(3, 'Arrowood'),
(10, 'Central Piedmont'),
(7, 'CTC/Arena'),
(8, 'Davidson Street'),
(11, 'Elizabeth Ave'),
(9, 'McDowell Street'),
(2, 'Sharon Rd West'),
(1, 'South Blvd'),
(5, 'Tyvola'),
(6, 'Woodlawn');

-- --------------------------------------------------------

--
-- Table structure for table `ticket`
--

CREATE TABLE `ticket` (
  `ticket_type` varchar(256) NOT NULL,
  `price` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ticket`
--

INSERT INTO `ticket` (`ticket_type`, `price`) VALUES
('monthly', 72),
('one-day', 5),
('two-hour', 2.25),
('weekly', 25);

-- --------------------------------------------------------

--
-- Table structure for table `train`
--

CREATE TABLE `train` (
  `id` int(11) NOT NULL,
  `route_name` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `train`
--

INSERT INTO `train` (`id`, `route_name`) VALUES
(444, 'blue'),
(555, 'blue'),
(666, 'blue'),
(333, 'green'),
(111, 'red'),
(222, 'red');

-- --------------------------------------------------------

--
-- Structure for view `admin_train_delay`
--
DROP TABLE IF EXISTS `admin_train_delay`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `admin_train_delay`  AS  select `schedule`.`estimated_time` AS `estimated_time`,`schedule`.`actual_time` AS `actual_time`,`schedule`.`train_id` AS `train_id`,`schedule`.`alert_message` AS `alert_message` from `schedule` where ((`schedule`.`train_status` = 'active') and (`schedule`.`station_status` = 'active') and (`schedule`.`estimated_time` <> `schedule`.`actual_time`)) ;

-- --------------------------------------------------------

--
-- Structure for view `passenger_route_station`
--
DROP TABLE IF EXISTS `passenger_route_station`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `passenger_route_station`  AS  select `t`.`route_name` AS `route_name`,`st`.`name` AS `station_name`,`s`.`train_id` AS `train_id`,`s`.`actual_time` AS `actual_time`,`s`.`id` AS `schedule_number`,`f_display_duration`(`s`.`train_id`,`st`.`id`,`s`.`id`) AS `Time left` from ((`schedule` `s` join `train` `t` on((`t`.`id` = `s`.`train_id`))) join `station` `st` on((`st`.`id` = `s`.`station_id`))) where ((`s`.`station_status` = 'active') and (`s`.`train_status` = 'active')) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`email_id`),
  ADD KEY `admin_index` (`email_id`);

--
-- Indexes for table `passenger`
--
ALTER TABLE `passenger`
  ADD PRIMARY KEY (`ticket_id`),
  ADD KEY `fk_schedule_id` (`schedule_id`),
  ADD KEY `passenger_index` (`ending_time`,`ticket_type`);

--
-- Indexes for table `route`
--
ALTER TABLE `route`
  ADD PRIMARY KEY (`name`),
  ADD KEY `route_index` (`name`);

--
-- Indexes for table `schedule`
--
ALTER TABLE `schedule`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_station_id` (`station_id`),
  ADD KEY `fk_train_id` (`train_id`),
  ADD KEY `schedule_index` (`actual_time`,`station_id`);

--
-- Indexes for table `station`
--
ALTER TABLE `station`
  ADD PRIMARY KEY (`id`),
  ADD KEY `station_index` (`name`);

--
-- Indexes for table `ticket`
--
ALTER TABLE `ticket`
  ADD PRIMARY KEY (`ticket_type`),
  ADD KEY `ticket_index` (`ticket_type`);

--
-- Indexes for table `train`
--
ALTER TABLE `train`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_route_name` (`route_name`),
  ADD KEY `train_index` (`route_name`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `passenger`
--
ALTER TABLE `passenger`
  MODIFY `ticket_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;
--
-- AUTO_INCREMENT for table `schedule`
--
ALTER TABLE `schedule`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=267;
--
-- AUTO_INCREMENT for table `station`
--
ALTER TABLE `station`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `passenger`
--
ALTER TABLE `passenger`
  ADD CONSTRAINT `fk_schedule_id` FOREIGN KEY (`schedule_id`) REFERENCES `schedule` (`id`);

--
-- Constraints for table `schedule`
--
ALTER TABLE `schedule`
  ADD CONSTRAINT `fk_station_id` FOREIGN KEY (`station_id`) REFERENCES `station` (`id`),
  ADD CONSTRAINT `fk_train_id` FOREIGN KEY (`train_id`) REFERENCES `train` (`id`);

--
-- Constraints for table `train`
--
ALTER TABLE `train`
  ADD CONSTRAINT `fk_route_name` FOREIGN KEY (`route_name`) REFERENCES `route` (`name`);

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `set_train_inactive` ON SCHEDULE EVERY 1 MINUTE STARTS '2017-12-03 01:57:06' ON COMPLETION PRESERVE ENABLE DO UPDATE Schedule
SET train_status='Inactive',station_status = 'Inactive', alert_message = NULL
WHERE CURRENT_TIMESTAMP>actual_time$$

CREATE DEFINER=`root`@`localhost` EVENT `set_ticket_inactive` ON SCHEDULE EVERY 1 SECOND STARTS '2017-12-03 02:00:37' ON COMPLETION PRESERVE ENABLE DO UPDATE Passenger set ticket_status = 'inactive' WHERE CURRENT_TIMESTAMP>ending_time$$

CREATE DEFINER=`root`@`localhost` EVENT `set_train_status` ON SCHEDULE EVERY 1 MINUTE STARTS '2017-11-16 00:00:00' ON COMPLETION PRESERVE ENABLE DO UPDATE Schedule SET actual_time = estimated_time, train_status = 'active', station_status='active', alert_message = NULL where CURRENT_TIMESTAMP < actual_time$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
