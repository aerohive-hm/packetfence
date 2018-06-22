
--
-- Setting the major/minor/sub-minor version of the DB
--

SET @MAJOR_VERSION = 1;
SET @MINOR_VERSION = 1;
SET @SUBMINOR_VERSION = 1;

--
-- The VERSION_INT to ensure proper ordering of the version in queries
--

SET @VERSION_INT = @MAJOR_VERSION << 16 | @MINOR_VERSION << 8 | @SUBMINOR_VERSION;

--
-- Updating to current version
--

INSERT INTO pf_version (id, version) VALUES (@VERSION_INT, CONCAT_WS('.', @MAJOR_VERSION, @MINOR_VERSION, @SUBMINOR_VERSION));
