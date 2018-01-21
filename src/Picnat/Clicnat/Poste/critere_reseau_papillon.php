<?php
namespace Picnat\Clicnat\Poste;

class critere_reseau_papillon extends bobs_extractions_conditions {
	function __construct() {
		parent::__construct();
	}

	public function __toString() {
		return '';
	}

	static public function get_titre() {
		return '';
	}

	public function get_sql() {
		return "especes.classe='I' and especes.ordre ilike 'l%pidopt%'";
	}

	public function get_tables() {
		return array('especes');
	}
}
