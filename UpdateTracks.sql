DELIMITER ;;
CREATE or replace DEFINER=`radiodj`@`%` PROCEDURE `UpdateTracks`(IN trackID INT, IN tType INT, IN curListeners INT, IN 
historyDays INT, IN pWeight DOUBLE)
BEGIN

/*Get the Artist name (why is this not an ID?)*/
SET @tArtist = (SELECT artist FROM songs WHERE ID=trackID);

/*Get the currently active studio*/
set @active_studio = (select studio from active_studio order by id desc limit 1);
set @current_user = (select left(user(), 3));

/*Only update if this is called by the active studio*/
if @active_studio = @current_user
then
  UPDATE `songs` SET `count_played`=`count_played`+1, `date_played`=NOW() WHERE `ID`=trackID;

  IF tType = 0 OR tType = 9 THEN
    UpDaTe `songs` SET `artist_played`=NOW() WHERE `artist`=@tArtist; /*Update artist_played*/
  END IF;
end if;

IF tType = 9 THEN
    UPDATE `requests` SET `played`=1 WHERE `songID`=trackID;
END IF;
IF pWeight>0 THEN
    UPDATE `songs` SET `weight`=`weight`-pWeight WHERE `ID`=trackID AND (`weight`-pWeight)>=0;
END IF;

IF historyDays > 0 THEN
    INSERT INTO `history`(date_played, song_type, id_subcat, id_genre, duration, artist, original_artist, title, album, 
composer, `year`, track_no, disc_no, publisher, copyright, isrc, listeners, user, songid)
    SELECT NOW(), song_type, id_subcat, id_genre, duration, artist, original_artist, title, album, composer, `year`, 
track_no, disc_no, publisher, copyright, isrc, curListeners, user(), trackID FROM `songs` WHERE ID=trackID;
END IF;
END ;;
DELIMITER ;
