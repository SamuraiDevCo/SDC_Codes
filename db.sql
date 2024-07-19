CREATE TABLE `sd_codes` (
  `identifier` VARCHAR(120) NOT NULL,
  `code` VARCHAR(12) NOT NULL,
  `uses` int(20) NOT NULL,
  `playtime` int(20) NOT NULL,
  `usedcodes` LONGTEXT NOT NULL,
  `usedfriendcodes` LONGTEXT NOT NULL,
  `rewardstoclaim` LONGTEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `sd_codes`
  ADD PRIMARY KEY (`identifier`)
;

CREATE TABLE `sd_createdcodes` (
  `code` VARCHAR(60) NOT NULL,
  `reward_data` LONGTEXT NOT NULL,
  `date_creation` datetime DEFAULT NULL,
  `date_deletion` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `sd_createdcodes`
  ADD PRIMARY KEY (`code`)
;