<?php
/* vim: set tabstop=4 noexpandtab: */
/**
 * Poste d'observation
 *
 * Directives de configuration
 *
 * - SMARTY_DIR : Repertoire d'installation de Smarty
 * - SMARTY_WDIR : Repertoire de travail de Smarty
 * - TITRE_PAGE : Titre des pages
 *
 **/

$start_time = microtime(true);

if (!defined('CONFIG_FILE'))
	define('CONFIG_FILE', '/etc/baseobs/config.php');

if (file_exists('config.php')) {
	require_once('config.php');
} else {
	if (!file_exists(CONFIG_FILE))
		die('Ne peut ouvrir le fichier de configuration '.CONFIG_FILE);

	require_once(CONFIG_FILE);
}
if (!defined('INSTALL'))
	define('INSTALL', 'picnat');

if (!defined('POSTE_BASE_URL')) 
	define('POSTE_BASE_URL', 'http://poste.obs.picardie-nature.org/');

if (!defined('POSTE_MAIL_SUPPORT')) 
	define('POSTE_MAIL_SUPPORT', 'support@picardie-nature.org');

if (!file_exists(SMARTY_COMPILE_POSTE))
	mkdir(SMARTY_COMPILE_POSTE);

define('TITRE_PAGE', "Base d'observations - Observateur");
define('TITRE_H1', 'Picardie-Nature');
define('TITRE_H2', TITRE_PAGE);
define('SESS', 'POST');
define('FORMAT_DATE_COMPLET', '%A %d %B %Y');
define('FORMAT_DATE_MOISJOUR', '%d %B');

define('LOCALE', 'fr_FR.UTF-8');

define('BOBS_POSTE_VS_X', 'poste_last_x');
define('BOBS_POSTE_VS_Y', 'poste_last_y');
define('BOBS_POSTE_VS_Z', 'poste_last_zoom');

require_once(OBS_DIR.'smarty.php');
require_once(OBS_DIR.'utilisateur.php');
require_once(OBS_DIR.'reseau.php');
require_once(OBS_DIR.'espace.php');
require_once(OBS_DIR.'espece.php');
require_once(OBS_DIR.'docs.php');
require_once(OBS_DIR.'chr.php');
require_once(OBS_DIR.'citations.php');
require_once(OBS_DIR.'observations.php');
require_once(OBS_DIR.'tags.php');
require_once(OBS_DIR.'extractions.php');
require_once(OBS_DIR.'extractions-conditions.php');
require_once(OBS_DIR.'calendriers.php');
require_once(OBS_DIR.'rss.php');
require_once(OBS_DIR.'selection.php');

$context = "poste";

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

class ExceptionErrAuth extends Exception {}
Class ExceptionReglement extends Exception {}

/**
 * @brief Site de saisie
 */
class Poste extends clicnat_smarty {
	function __construct($db) {
		parent::__construct($db, SMARTY_TEMPLATE_POSTE, SMARTY_COMPILE_POSTE, SMARTY_CONFIG_POSTE);
		$this->cache_dir = '/tmp/cache_poste';
		if (!file_exists('/tmp/cache_poste')) mkdir('/tmp/cache_poste');
		
	}

	private function template($selection_tpl = false) {
		$template = (empty($_POST['t'])?(empty($_GET['t'])?'accueil':$_GET['t']):$_POST['t']);
		return $template;
	}

	protected function default_assign() {
		$this->assign('app_titre', TITRE_PAGE);
		$this->assign('titre_h1', TITRE_H1);
		$this->assign('titre_h2', TITRE_H2);
		$this->assign('google_key', GOOGLE_KEY_POSTE);
		$this->assign('format_date_complet', FORMAT_DATE_COMPLET);
		$this->assign('format_date_moisjour', FORMAT_DATE_MOISJOUR);
		$this->assign('install', INSTALL);
	}

	protected function session() {
		session_start();
		$this->assign('auth_ok', false);
		if (array_key_exists(SESS, $_SESSION)) {
			if (array_key_exists('auth_ok', $_SESSION[SESS]))
				if ($_SESSION[SESS]['auth_ok']) 
					$this->assign('auth_ok', true);
		} else {
			$_SESSION[SESS] = array('auth_ok' => false);
		}

		if (isset($_SESSION['msgs'])) {
			$this->bobs_msgs = $_SESSION['msgs'];
			unset($_SESSION['msgs']);
		} else {
			$this->bobs_msgs = array();
		}
	}

	const v_sess_recherche = 'prec_rech_util';

	protected function before_recherche_utilisateur_sauve_resultat() {
		self::cls($_GET['ids']);
		$_SESSION[SESS][self::v_sess_recherche] = $_GET['ids'];
		exit();
	}

	protected function before_tag_infos() {
		$this->assign('tag', new bobs_tags($this->db, (int)$_GET['id']));
	}

	protected function before_recherche_utilisateur_restaure_resultat() {
		$t = explode(',', $_SESSION[SESS][self::v_sess_recherche]);
		$tr = array();
		foreach ($t as $p) {
			$po = new bobs_utilisateur($this->db, $p);
			$tr[] = array('id' => $po->id_utilisateur, 'nom' => $po->__toString());
		}
		echo json_encode($tr);
		exit();
	}

	protected function before_profil() {
		$u = $this->get_user_session();
	}

	protected function before_fichier() {
		$u = $this->get_user_session();
		$f = $u->fichier($_GET['id']);
		header("Content-Type: {$f->file['content_type']}");
		header("Content-Disposition: attachment; filename=\"{$f->file['filename']}\"");
		echo $f->getBytes();
		exit();
	}

	protected function before_journal() {
		$u = $this->get_user_session();
		$id_utilisateur = $u->id_utilisateur;

		if (!isset($_GET['act'])) $_GET['act'] = 'null';

		if (empty($_SESSION[SESS]['extraction']) or $_GET['act']=='reset') {
			$_SESSION[SESS]['extraction'] = new bobs_extractions_poste($this->db, $id_utilisateur);
		}
		$extract = $_SESSION[SESS]['extraction'];

		// il est perdu dans la session
		$extract->set_db($this->db);

		$this->assign_by_ref('extract', $extract);
		if (array_key_exists('classe', $_GET)) {
			switch ($_GET['classe']) {
				case 'bobs_ext_c_zps':
					$espaces_zps = bobs_espace_zps::get_list($this->db);
					$this->assign_by_ref('espaces_zps', $espaces_zps);
					break;
				case 'bobs_ext_c_zsc':
					$espaces_zsc = bobs_espace_zsc::get_list($this->db);
					$this->assign_by_ref('espaces_zsc', $espaces_zsc);
					break;
				case 'bobs_ext_c_ordre':
					$ordres = bobs_espece::get_ordres($this->db);
					$this->assign_by_ref('ordres', $ordres);
					break;
				case 'bobs_ext_c_epci':
					$espace_epci = bobs_espace_epci::get_list($this->db);
					$this->assign_by_ref('espaces_epci', $espace_epci);
					break;
				case 'bobs_ext_c_structure':
					$espace_structure = bobs_espace_structure::get_list($this->db);
					$this->assign_by_ref('espaces_structure', $espace_structure);
					break;
				case 'bobs_ext_c_liste_especes':
					require_once(OBS_DIR.'liste_espece.php');
					$liste_a = clicnat_listes_especes::liste_public($this->db);
					$liste_b = clicnat_listes_especes::liste($this->db, $u->id_utilisateur);
					$u = $this->get_user_session();
					$this->assign_by_ref('liste_public', $liste_a);
					$this->assign_by_ref('liste_perso', $liste_b);
					break;
				case 'bobs_ext_c_tag_structure':
					$this->assign_by_ref('structures', get_config()->structures());
					break;
				case 'bobs_ext_c_tag_protocole':
					$this->assign_by_ref('protocoles', get_config()->protocoles());
					break;
				case 'bobs_ext_c_classe':
					$classes = array();
					foreach (bobs_classe::get_classes() as $c) {
						$classe = new bobs_classe($this->db, $c);
						$classes[] = array("id" => $c, "lib" => $classe->__toString());
					}
					$this->assign_by_ref('classes', $classes);
					break;
				case 'bobs_ext_c_reseau':
					$this->assign_by_ref('reseaux', bobs_reseaux_liste($this->db));
					break;
				case 'bobs_ext_c_departement':
					$l_depts = explode(',',DEPARTEMENTS);
					$depts = [];
					foreach ($l_depts as $dept)
						$depts[] = new bobs_espace_departement($this->db, $dept);
					$this->assign_by_ref('departements', $depts);
					break;
			}
		}
		$recalcul = false;
		if (array_key_exists('act', $_GET)) {
			switch ($_GET['act']) {
				case 'condition_retirer':
					$this->assign('act', 'condition_retirer');
					$extract->retirer_condition(bobs_element::cli($_GET['n']));
					$recalcul = true;
					break;
				case 'condition_ajoute':
					$this->assign('act', 'condition_ajoute');
					$this->assign('cl', basename($_GET['classe']));
					break;
				case 'condition_enreg':
					$conditions = bobs_extractions_poste::get_conditions_dispo();
					if (!array_key_exists($_POST['classe'], $conditions)) {
						throw new Exception('classe non gérée ici');
					}
					$cond = eval("return {$_POST['classe']}::new_by_array(\$_POST);");
					$extract->ajouter_condition($cond);
					$recalcul = true;
					break;
				case 'selection_new':
					bobs_element::cls($_POST['sname']);
					if (empty($_POST['sname'])) $_POST['sname'] = 'sans nom';
					$id_selection = $u->selection_creer($_POST['sname']);
					$extract->dans_selection($id_selection);
					$this->assign('id_selection', $id_selection);
					$this->assign('act', 'selection_new');
					$this->assign('msg', "Nouvelle sélection enregistrée");
					break;
				case 'extraction_sauve':
					self::cls($_POST['ename']);
					if (empty($_POST['ename'])) $_POST['ename'] = 'sans nom';
					$u->extraction_ajoute($extract->sauve_xml($_POST['ename']));
					$this->assign('msg', "définition de l'extraction enregistrée");
					break;
				case 'extraction_charge':
					self::cli($_GET['id'], bobs_tests::except_si_inf_1);
					$extract = $u->extraction_charge($_GET['id']);
					$_SESSION[SESS]['extraction'] = $extract;
					$this->assign_by_ref('extract', $extract);
					$this->assign('msg', "définition de l'extraction chargée");
					$recalcul = true;
					break;
				case 'extraction_charge_selection':
					self::cli($_GET['id'], bobs_tests::except_si_inf_1);
					$selection = $u->selection_get($_GET['id']);
					$extract = bobs_extractions::charge_xml($this->db, $selection->extraction_xml, $u->id_utilisateur);
					$_SESSION[SESS]['extraction'] = $extract;
					$this->assign_by_ref('extract', $extract);
					$this->assign('msg', "définition de l'extraction chargée");
					$recalcul = true;
					break;
				case 'extraction_supprime':
					self::cli($_GET['id'], bobs_tests::except_si_inf_1);
					$u->extraction_supprime($_GET['id']);
					$this->assign('msg', "définition de l'extraction supprimée");
					break;
				case 'extraction_choix_flux':
					self::cli($_GET['id'], bobs_tests::except_si_inf_1);
					if ($u->update_field('id_extraction_utilisateur_flux', $_GET['id']))
						$this->assign('msg', 'Choix enregistré, fermez et ouvrez votre session');
					else
						$this->assign('msg', 'Erreur enregistrement choix');
					break;
			}
		}
		if ($extract->ready()) {
			if ($recalcul)
				$_SESSION[SESS]['extraction_n'] = $extract->compte();
			$this->assign('compte', $_SESSION[SESS]['extraction_n']);
		}
	}

	protected function before_inscription() {
		$this->assign('suivi', false);
		if (array_key_exists('ins', $_POST)) {
			$pre = new bobs_utilisateur_preinscription();
			try {
				$pre->set_vars($_POST);
			} catch (Exception $e) {
				$this->assign('retry', true);
				$this->assign_by_ref('pre', $pre);
				return;
			}
			$pre->sauve_et_envoi_mail(POSTE_BASE_URL, POSTE_MAIL_SUPPORT, SIGNATURE);
			$this->assign('mail_ok', true);
		} else {
			if (array_key_exists('suivi', $_GET)) {
				$this->assign('suivi', true);
				try {
					$pre = bobs_utilisateur_preinscription::reprise($_GET['suivi']);
					$this->assign('pre', $pre);
				} catch (Exception $e) {
					$this->assign('suivi_inconnu', true);
					return;
				}
				// Confirmation faite ?
				if (array_key_exists('ok', $_POST)) {
					$this->assign('confirmation_ok', true);
					$pre->creation_compte($this->db, POSTE_BASE_URL, POSTE_MAIL_SUPPORT, SIGNATURE);
				} else {
					$this->assign('confirmation_ok', false);
				}
			}
		}
	}

	protected function before_accueil() {
		$_POST['act']=array_key_exists('act', $_POST)?self::cls($_POST['act']):null;
		$_POST['username']=array_key_exists('username', $_POST)?self::cls($_POST['username']):null;
		$_POST['password']=array_key_exists('password', $_POST)?self::cls($_POST['password']):null;

		$this->assign('mad', false);

		if ($_POST['act'] == 'login') {
			if (empty($_POST['username']))
				return;
			$u = bobs_utilisateur::by_login($this->db, $_POST['username']);
			if ($u && $u->auth_ok($_POST['password'])) {
				$this->assign('username', $u->username);
				$this->assign('id_utilisateur', $u->id_utilisateur);
				$this->assign('auth_ok', true);
				$this->assign('messageinfo', 'Bienvenue');

				$redir = '?t=accueil';				
				if (!empty($_POST['redir'])) 
					$redir = str_replace('"', '', $_POST['redir']);
				$this->assign('redir', $redir);

				$u->mise_a_disposition();

				// on ne l'utilise pas mais on veux que ce soit
				// dans l'objet qui va être "sérialisé"
				$u->get_reseaux();

				//$this->assign('mad', true);
				$_SESSION[SESS]['auth_ok'] = true;
				$_SESSION[SESS]['id_utilisateur'] = $u->id_utilisateur;
				$_SESSION[SESS]['utilisateur'] = serialize($u);
				bobs_log(sprintf("login user id %d ok", $u->id_utilisateur));
			} else {
				$_SESSION[SESS]['auth_ok'] = false;
				$this->assign('auth_ok', false);
				$this->assign('messageinfo', "Nom d'utilisateur ou mot de passe incorrect");
				return;
			}
		} else if (isset($_GET['fermer'])) {
			$this->assign('auth_ok', false);
			$this->assign('messageinfo', "Vous êtes déconnecté");
			$_SESSION[SESS]['auth_ok'] = false;
			session_destroy();
			return;
		} else if (isset($_GET['ticket'])) {
			try {
				$u_req = bobs_utilisateur::by_mail($this->db, $_GET['adr']);
				if ($u_req->ticket_mot_de_passe != $_GET['ticket'])
					throw new Exception('Ticket invalide');
				$u_req->send_password(POSTE_BASE_URL, POSTE_MAIL_SUPPORT, SIGNATURE);
				$this->assign('msg_mdp', 'Vous devriez recevoir un mail avec votre mot de passe');
			} catch (Exception $e) {
				$this->assign('msg_mdp', "Ticket ou compte introuvable, contactez nous <!-- {$e->getMessage()} -->");
			}
		} else if (!empty($_POST['adr'])) {
			try {
				$u_req = bobs_utilisateur::by_mail($this->db, $_POST['adr']);
				if ($u_req) {
					$u_req->envoi_mail_confirmation_demande(POSTE_BASE_URL, POSTE_MAIL_SUPPORT, SIGNATURE);
				} else {
					throw new Exception('pas trouvé');
				}
				$this->assign('msg_mdp', 'Vous devriez recevoir un mail avec votre mot de passe');
			} catch (Exception $e) {
				$this->assign('msg_mdp', "Adresse e-mail introuvable, vérifier votre adresse ou contactez nous <!-- {$e->getMessage()} -->");
			}
		}
		
		$this->assign('u', $this->get_user_session());
		
		if ($_SESSION[SESS]['auth_ok'] == true) {
			$u = $this->get_user_session();
			$extr = new bobs_extractions($this->db);
			$extr->ajouter_condition(new bobs_ext_c_observateur($u->id_utilisateur));
			$extr->ajouter_condition(new bobs_ext_c_interval_date(strftime('%d-%m-%Y', mktime()-86400*120), strftime('%d-%m-%Y', mktime())));
			$t = $extr->dans_un_tableau();
			krsort($t);
			$this->assign_by_ref('dernieres_obs',$t);
                	$this->assign_by_ref("reseau_sc", new bobs_reseau($this->db,'sc'));
		}
	}

	protected function before_espece_ajout_mnhn() {
		$u = $this->get_user_session();
		if (!$u->peut_ajouter_espece)
			throw new Exception('pas autorisé a ajouter des espèces');

		if (isset($_GET['id'])) {
			$esp = new bobs_espece_inpn($this->db, (int)$_GET['id']);
			if (isset($_GET['ajouter'])) {
				$ne_id = $esp->insert_in_especes();
				$ne = get_espece($this->db, $ne_id);
				$ne->set_expert(true);
			}
			$esp = new bobs_espece_inpn($this->db, (int)$_GET['id']);
			$this->assign('espece_inpn', $esp);
		}
	}
	protected function before_listes_especes() {
		require_once(OBS_DIR.'liste_espece.php');
		$u = $this->get_user_session();
		if (array_key_exists('nouveau_nom', $_POST)) {
			bobs_tests::cls($_POST['nouveau_nom'], bobs_tests::except_si_vide);
			clicnat_listes_especes::creer($this->db, $u->id_utilisateur, htmlentities($_POST['nouveau_nom'],ENT_QUOTES,'UTF-8'));
		}
	}

	protected function before_listes_espaces() {
		require_once(OBS_DIR.'liste_espace.php');
		$u = $this->get_user_session();
		if (array_key_exists('nouveau_nom', $_POST)) {
			bobs_tests::cls($_POST['nouveau_nom'], bobs_tests::except_si_vide);
			clicnat_listes_espaces::creer($this->db, $u->id_utilisateur, htmlentities($_POST['nouveau_nom'],ENT_QUOTES,'UTF-8'));
		}

	}

	protected function before_liste_espece() {
		require_once(OBS_DIR.'liste_espece.php');
		$u = $this->get_user_session();
		$l = new clicnat_listes_especes($this->db, $_GET['id']);
		if ($l->id_utilisateur != $u->id_utilisateur) {
			throw new Exception('vous avez pas le droit de la voir');
		}

		if (array_key_exists('inpn_liste_espece', $_POST)) {
			$t = $l->ajouter_liste_id_mnhn($_POST['inpn_liste_espece']);
			$this->assign_by_ref('tab_inpn_erreurs', $t);
		}
		if (array_key_exists('id_especes_liste_espece', $_POST)) {
			$t = $l->ajouter_liste_id_espece($_POST['id_especes_liste_espece']);
			$this->assign_by_ref('tab_id_erreurs', $t);
		}
		if (array_key_exists('nom_especes_liste_especes', $_POST)) {
			$t = $l->ajouter_liste_nom_espece($_POST['nom_especes_liste_especes']);
			$this->assign_by_ref('tab_nom_erreurs', $t);
		}
		if (array_key_exists('vider', $_GET)) {
			$l->vider();
		}
		if (array_key_exists('supprimer', $_GET)) {
			$l->supprimer();
			$this->redirect('?t=listes_especes');
			exit();
		}
		if (array_key_exists('retirer_id_espece', $_GET)) {
			$l->retirer((int)$_GET['retirer_id_espece']);
			$this->redirect('?t=liste_espece&id='.$l->id_liste_espece);
		}
		$this->assign_by_ref('liste', $l);
	}

	protected function before_liste_espace_carte() {
		require_once(OBS_DIR.'liste_espace.php');
		$u = $this->get_user_session();
		$l = new clicnat_listes_espaces($this->db, $_GET['id']);
		if (($l->ref == true) or ($l->id_utilisateur == $u->id_utilisateur)) {
			$this->assign('l', $l);
		} else {
			$this->bobs_msgs[] = 'Vous ne pouvez pas consulter cette carte';
		}
	}
	protected function before_liste_espace_carte_fs() {
		require_once(OBS_DIR.'liste_espace.php');
		$u = $this->get_user_session();
		$l = new clicnat_listes_espaces($this->db, $_GET['id']);
		if (($l->ref == true) or ($l->id_utilisateur == $u->id_utilisateur)) {
			$this->assign('l', $l);
		} else {
			$this->bobs_msgs[] = 'Vous ne pouvez pas consulter cette carte';
		}
	}


	protected function before_amphibiens_reptiles_carto() {
		require_once(OBS_DIR.'liste_espace.php');
		$passages = new clicnat_listes_espaces($this->db, 2);
		$pointsnoirs = new clicnat_listes_espaces($this->db, 3);
		$this->assign_by_ref('passages', $passages);
		$this->assign_by_ref('pointsnoirs', $pointsnoirs);
	}

	protected function before_liste_espace_carte_wfs() {
		require_once(OBS_DIR.'liste_espace.php');
		require_once(OBS_DIR.'wfs.php');
		$data = file_get_contents('php://input'); // contenu de _POST
		$doc = new DomDocument();
		@$doc->loadXML($data);
		header('Content-type: text/xml');
		$gf = new clicnat_wfs_get_feature($this->db, $doc);
		$sel = $gf->get_liste_espaces();
		$u = $this->get_user_session();
		if (($u->id_utilisateur == $sel->id_utilisateur) || $sel->ref)
			echo $gf->reponse()->saveXML();
		else
			//WFS Exception
			throw new Exception('WFS Exception...');
		exit();
	}

	protected function before_liste_espace() {
		require_once(OBS_DIR.'liste_espace.php');
		$u = $this->get_user_session();
		$l = new clicnat_listes_espaces($this->db, $_GET['id']);
		if (!($l->id_utilisateur == $u->id_utilisateur) && !$u->acces_qg_ok()) {
			throw new Exception('vous avez pas le droit de la voir');
		}
		if (array_key_exists('vider', $_GET)) {
			$l->vider();
		} elseif (array_key_exists('supprimer', $_GET)) {
			$l->supprimer();
			$this->redirect('?t=listes_espaces');
			exit();
		} elseif (array_key_exists('ajouter_ids', $_POST)) {
			$l->ajouter_liste_ids($_POST['ajouter_ids']);
		} elseif (array_key_exists('nom', $_POST)||array_key_exists('mention', $_POST)) {
			if (array_key_exists('nom', $_POST)) $l->modifier_nom($_POST['nom']);
			if (array_key_exists('mention', $_POST)) $l->modifier_mention($_POST['mention']);
		} elseif (array_key_exists('enlever', $_GET)) {
			$l->enlever($_GET['enlever']);
			$this->redirect('?t=liste_espace&id='.$l->id_liste_espace);
			exit();
		} elseif (array_key_exists('renomme', $_GET)) {
			foreach ($l->get_espaces() as $e) {
				if ($e->id_espace == $_GET['id_espace']) {
					self::cls($_GET['renomme']);
					if (!empty($_GET['renomme']))
						$e->renomme($_GET['renomme']);
				}
			}
			$this->redirect('?t=liste_espace&id='.$l->id_liste_espace);
		} elseif (isset($_GET['telecharger_kml'])) {
			header('Content-Type: application/vnd.google-earth.kml+xml kml');
			header('Content-Disposition: attachment; filename="liste_espaces_'.$l->id_liste_espace.'.kml"');
			$doc = $l->kml();
			echo $doc->saveXML();
			exit();
		} elseif (isset($_GET['telecharger_shp_englob'])) {
			self::header_zip();
			self::header_filename("liste_espace_englob_{$l->id_liste_espace}.zip");
			$l->shp_englobant();
			exit();
		} elseif (isset($_FILES['kml'])) {
			$xml = file_get_contents($_FILES['kml']['tmp_name']);
			file_put_contents("/tmp/le_imp_{$l->id_liste_espace}.kml", $xml);
			$doc = new DOMDocument();
			$doc->loadXML($xml);
			$this->assign_by_ref('choix_import_kml', $l->import_kml_liste_champs($doc));
		} elseif (isset($_GET['import_kml_suite'])) {
			$f = "/tmp/le_imp_{$l->id_liste_espace}.kml";
			if (file_exists($f)) {
				$attrs = array();
				if (isset($_GET['nom']) && !empty($_GET['nom'])) $attrs['nom'] = $_GET['nom'];
				if (isset($_GET['reference']) && !empty($_GET['reference'])) $attrs['reference'] = $_GET['reference'];
				$xml = file_get_contents($f);
				$l->import_kml($xml, $u, $attrs);
				unlink($f);
			}
		}
		if (isset($_POST['action'])) {
			switch ($_POST['action']) {
				case "ajouter_attribut":
					print_r($_POST);
					$l->attributs_def_ajout_champ($_POST['name'], $_POST['type'], $_POST['values']);
					break;
				default:
					throw new Exception("action inconnue");
			}
		}
		$this->assign_by_ref('liste', $l);
	}

	protected function before_reseau() {
		$this->assign_by_ref('reseaux', bobs_reseaux_liste($this->db));
		if (array_key_exists('id', $_GET)) {
			$this->assign_by_ref('reseau', get_bobs_reseau($this->db, $_GET['id']));
		}
	}

	protected function before_mapage() {
		$u = $this->get_user_session();
		if (isset($_GET['y'])) {
			self::cli($_GET['y']);
			$this->assign('y', sprintf('%04d', $_GET['y']));
		} else {
			$this->assign('y', strftime('%Y'));
		}
		if (isset($_GET['act'])) {
			$ok = true;
			switch ($_GET['act']) {
				case 'mdp':
					self::cls($_POST['p1']);
					self::cls($_POST['p2']);
					if (!empty($_POST['p1']) && $_POST['p1'] == $_POST['p2'] && strlen($_POST['p1'])>=7) {
						$u->set_password($_POST['p1']);
						$this->assign('message_mdp', 'Nouveau mot de passe enregistré');
					} else {
						$ok = false;
						if (empty($_POST['p1'])) {
							$this->assign('message_mdp', "Erreur : mot de passe vide");
						} else if (empty($_POST['p2'])) {
							$this->assign('message_mdp', "Erreur : vous devez confirmer le mot de passe");
						} else if (strlen($_POST['p1']) < 7) {
							$this->assign('message_mdp', "Erreur : Trop court (7 caractères minimum)");
						} else if ($_POST['p1'] != $_POST['p2']) {
							$this->assign('message_mdp', "Erreur : Mots de passe différents");
						}
					}
					break;
				case 'mail':
					self::cls($_POST['mail']);
					try {
						$u->set_mail($_POST['mail']);
						$this->assign('message_mail', 'Adresse mise à jour');
						$this->get_user_session(true);
					} catch (Exception $e) {
						$ok = false;
						$this->assign('message_mail', 'Erreur lors de la mise a jour de votre adresse vérifier votre saisie');
					}
					break;
				case 'date_naissance':
					self::cls($_POST['date_naissance']);
					try {
						$u->set_date_naissance($_POST['date_naissance']);
						$this->assign('message_date', 'Date mise à jour');
						$this->get_user_session(true);
					} catch (Exception $e) {
						$ok = false;
						$this->assign('message_date', 'Erreur lors de la mise a jour de votre date de naissance vérifier votre saisie');
					}
					break;

				case 'expert':
					$u->set_expert($_GET['v']==1);
					break;
				case 'options':
					$u->partage_opts_set($_POST['partage_opts']);
					break;
			}
			$_SESSION[SESS]['utilisateur'] = serialize(new bobs_utilisateur($this->db, $u->id_utilisateur));
			$this->redirect('?t=mapage');
		}
	}

	protected function before_malocalisation() {
		$u = $this->get_user_session();
		$this->assign('xorg', CLICNAT_X_ORG);
		$this->assign('yorg', CLICNAT_Y_ORG);
		$this->assign('zorg', CLICNAT_Z_ORG);

		if (array_key_exists('lat', $_POST) && array_key_exists('lon', $_POST)) {
			$u->set_localisation(sprintf("POINT(%F %F)", (float)$_POST['lon'], (float)$_POST['lat']));
			$this->bobs_msgs[] = 'Localisation mise à jour';
		}
	}
	protected function before_madate_naissance(){
		$u = $this->get_user_session();
		$this->assign('date_jour',time());
		if (isset($_POST['date_naissance']) && $_POST['date_naissance'] != ""){
			$u->set_date_naissance($_POST['date_naissance']);
			$_SESSION[SESS]['utilisateur'] = serialize($u);
			$this->bobs_msgs[] = 'Date de naissance mise à jour ';
			$this->redirect('?t=mapage');
		}

	}

	protected function before_mes_obs_par_mois() {
		$u = $this->get_user_session();
		if (!isset($_GET['y'])) $y = strftime("%Y");
		else $y = (int)$_GET['y'];
		$this->header_json();
		echo json_encode($u->get_n_obs_par_mois($y));
		exit();
	}
	
	protected function before_espece_detail() {
		$id = $_GET['id'];
		self::cli($id, bobs_tests::except_si_inf_1);

		if (empty($id))
			throw new Exception('id espece vide');

		$u = $this->get_user_session();
		$espece = get_espece($this->db, $id);
		$chaine_md5 = sprintf("%s%s", empty($espece->ordre)?'NULL':$espece->ordre, $espece->classe);
		$this->assign('md5_ordre', md5($chaine_md5));
		$this->assign_by_ref('esp', $espece);		
		$this->assign('usemap', true);	
		$this->assign('borne_a', intval(strftime("%Y"))-5);
		$this->assign('borne_b', intval(strftime("%Y"))-10);
		$ext_mes_obs = new bobs_extractions($this->db);		
		$ext_mes_obs->ajouter_condition(new bobs_ext_c_observateur($u->id_utilisateur));
		$ext_mes_obs->ajouter_condition(new bobs_ext_c_espece($espece->id_espece));
		$this->assign_by_ref('mes_obs', $ext_mes_obs);
	}
	
	protected function before_ch() {
		$comite = get_chr($this->db, $_GET['id']);
		$this->assign_by_ref('comite', $comite);	
	}

	protected function before_redirection_archives_geor() {
		$u = $this->get_user_session();
		if ($u->membre_reseau('av')) {
			$f  = fopen("http://10.10.0.7/biblio/?action=jeton_creer&cats=9",'r');
			$jeton = trim(fgets($f),"\n");
			fclose($f);
			$suiv = urlencode("?action=lecteur&document=162");
			header("Location: http://archives.picardie-nature.org/?action=jeton_utilise&jeton=$jeton&suiv=$suiv");
		}
	}
	protected function before_atlas_oiseaux_hivernants_espece() {	
		$this->assign('usemap', true);	
		$u = $this->get_user_session();
		$espece = get_espece($this->db, $_GET['id']);
		$this->assign_by_ref('esp', $espece);
		if ($u->membre_reseau('av')) {
			$this->assign_by_ref('hivernants', bobs_espece::liste_oiseaux_hivernant_2009_a_2011($this->db));
			$this->assign('pas_membre', false);
		} else {
			$this->assign('pas_membre', true);
		}
	}
	protected function before_atlas_hivernant() {
		$u = $this->get_user_session();
		if ($u->membre_reseau('av')) {
			$this->assign('usemap', true);
			$this->assign_by_ref('hivernants', bobs_espece::liste_oiseaux_hivernant_2009_a_2011($this->db));
			$this->assign_by_ref('carres', bobs_espace_l93_10x10::tous($this->db));
			$compte = bobs_espace_l93_10x10::get_nb_especes_carres_hivernants_2010_2011($this->db);
			$the_compte = array();
			foreach ($compte as $c) {
				$the_compte[$c['nom']] = $c['n'];
			}
			$this->assign_by_ref('compte', $the_compte);
			$this->assign('pas_membre', false);
		} else {
			$this->assign('pas_membre', true);
		}
	}
	protected function before_atlas_oiseaux_nicheurs_carte_resp() {
		require_once(OBS_DIR.'aonfm.php');
		$u = $this->get_user_session();
		if ($u->membre_reseau('av')) {
			$this->assign('usemap', true);

			$this->assign('c_possible', bobs_aonfm::couleur_possible);
			$this->assign('c_probable', bobs_aonfm::couleur_probable);
			$this->assign('c_certain', bobs_aonfm::couleur_certain);

			$resultats = bobs_aonfm::nb_especes_carres_choix_resp($this->db);
			$this->assign_by_ref('resultats', $resultats);
		}
	}

	protected function before_atlas_oiseaux_nicheurs() {
		require_once(OBS_DIR.'aonfm.php');
		$u = $this->get_user_session();

		if ($u->membre_reseau('av')) {
			$this->caching = 2;
			$this->cache_lifetime = 3600*8; // 8h
			if (isset($_GET['recalcul'])) 
				$this->clear_cache('atlas_oiseaux_nicheurs.tpl');
			if (!$this->is_cached('atlas_oiseaux_nicheurs.tpl')) {
					$this->assign('usemap', true);
					
					$this->assign('c_possible', bobs_aonfm::couleur_possible);
					$this->assign('c_probable', bobs_aonfm::couleur_probable);
					$this->assign('c_certain', bobs_aonfm::couleur_certain);
					
					$carres = bobs_espace_l93_10x10::tous($this->db);
					$this->assign_by_ref('carres', $carres);
					foreach ($carres as $car) {
						$n = bobs_aonfm::nb_especes_carre($car['id_espace']);
						if (empty($n)) $n = 0;
						$the_compte[$car['nom']] = $n;
					}
					$this->assign_by_ref('compte', $the_compte);
					$this->assign('pas_membre', false);
			}
			parent::display('atlas_oiseaux_nicheurs.tpl');
			exit();
		} else {
			$this->assign('pas_membre', true);
		}
	}
	
	protected function before_atlas_oiseaux_nicheurs_xml() {
		if (!file_exists('/tmp/aonfm.xml'))
			throw new Exception('pas généré...');
		header("content-type: application/xml");
		echo file_get_contents('/tmp/aonfm.xml');
		exit();
	}

	protected function before_atlas_oiseaux_nicheurs_xml_winter() {
		if (!file_exists('/tmp/aohfm.xml'))
			throw new Exception('pas généré...');
		header("content-type: application/xml");
		echo file_get_contents('/tmp/aohfm.xml');
		exit();
	}

	
	protected function before_atlas_oiseaux_nicheurs_espece() {
		require_once(OBS_DIR.'aonfm.php');
		
		$u = $this->get_user_session();
		$espece = get_espece($this->db, (int)$_GET['id']);
		$this->assign_by_ref('espece', $espece);
		if ($u->membre_reseau('av')) {
			$this->assign('usemap', true);
			
			$carres = bobs_aonfm::carres_espece($this->db, $espece->id_espece);
			
			$this->assign('c_possible', bobs_aonfm::couleur_possible);
			$this->assign('c_probable', bobs_aonfm::couleur_probable);
			$this->assign('c_certain', bobs_aonfm::couleur_certain);
			
			$this->assign_by_ref('carres', $carres);
			$this->assign('pas_membre', false);
		} else {
			$this->assign('pas_membre', true);
		}
	}


	protected function before_atlas_oiseaux_nicheurs_r_carre() {
		require_once(OBS_DIR.'aonfm.php');
		if (array_key_exists('nom', $_GET)) {
			$esp = bobs_espace_l93_10x10::get_by_nom($this->db, $_GET['nom']);
			if ($esp)
				$_GET['id_espace'] = $esp->id_espace;
			else
				throw new Exception('carré pas trouvé');
		}
		$msgs = array();
		$u = $this->get_user_session();
		if ($u->membre_reseau('av')) {
			if (array_key_exists('ajoute_espece', $_GET)) {
				$espece = get_espece($this->db, $_GET['ajoute_espece']);
				if ($espece->classe != 'O') {
					throw new Exception('que des oiseaux');
				}
				$ok = false; 
				foreach ($u->liste_carre_atlas() as $c) {
					if ($c['id_espace'] == $_GET['id_espace']) {
						$ok = $c['decideur_aonfm'] == 't';
						break;
					}
				}
				if (!$ok) {
					$msgs[] = "Ne peut ajouter l'espèce, pas responsable du carré";
				} else {
					switch($_GET['annee']) {
						case '2011': $annee = 2011; break;
						case '2012': $annee = 2012; break;
						case '2010': $annee = 2010; break;
						case '2009': $annee = 2009; break;
						default: $annee = 2012; break;
					}
					$rest = new bobs_aonfm_restitution_carre($this->db, $_GET['id_espace'], $annee);
					if ($rest->set_resultats_responsables($_GET['ajoute_espece'], -1, 'A', $u, true)) {
						header('Location: ?t=atlas_oiseaux_nicheurs_r_carre&id_espace='.$_GET['id_espace']);
						exit();
					} else {
						$msgs[] = "{$espece} pas ajouté, peut être déjà présent...";
					}
				}
			}
			$c = get_espace_l93_10x10($this->db, $_GET['id_espace']);
			$this->assign_by_ref('carre', $c);
			$this->assign_by_ref('t', $t);

			$trois = bobs_aonfm_restitution_carre::trois_annees($this->db, $_GET['id_espace']);
			$this->assign_by_ref('trois', $trois);
		}
		$this->assign_by_ref('msgs', $msgs);
	}

	protected function before_altas_oiseaux_nicheurs_r_carre_get_abondance() {
		require_once(OBS_DIR.'aonfm.php');
		$u = $this->get_user_session();
		// tester si proprio du carré
		$ok = false;
		foreach ($u->liste_carre_atlas() as $c) {
			if ($c['id_espace'] == $_GET['id_espace']) {
				$ok = $c['decideur_aonfm'] == 't';
				break;
			}
		}
		if (!$ok) {
			echo "Il faut être responsable du carré <a href=javascript:fermer();>fermer</a>";
			exit();
		}
		$r = bobs_aonfm_choix_resp_tps_abond::get($this->db, $_GET['id_espace'], $_GET['id_espece']);
		echo json_encode($r);
		exit();
	}

	protected function before_altas_oiseaux_nicheurs_r_carre_enreg_abondance() {
		require_once(OBS_DIR.'aonfm.php');
		$u = $this->get_user_session();
		// tester si proprio du carré
		$ok = false;
		foreach ($u->liste_carre_atlas() as $c) {
			if ($c['id_espace'] == $_GET['id_espace']) {
				$ok = $c['decideur_aonfm'] == 't';
				break;
			}
		}
		if (!$ok) {
			echo "Il faut être responsable du carré <a href=javascript:fermer();>fermer</a>";
			exit();
		}

		if ($u->membre_reseau('av')) {
			$id_espece = $_GET['id_espece'];
			$id_espace = $_GET['id_espace'];
			$abondance_liste = $_GET['fp']=='null'?$_GET['fl']:$_GET['fp'];
			$abondance_n = $_GET['cp'];
			if ($abondance_liste == 'null') $abondance_liste = 0;
			bobs_aonfm_choix_resp_tps_abond:: enregistrer($this->db,$id_espace,$id_espece,$abondance_liste,$abondance_n);
			echo "Ok";
			exit();
		} else {
			echo "Pas enregistré comme membre du réseau avifaune <a href=javascript:fermer();>fermer</a>";
			exit();
		}
		echo 'Erreur inconnue <a href=javascript:fermer();">fermer</a>';
		exit();
	}

	protected function before_atlas_oiseaux_nicheurs_r_carre_enreg() {
		require_once(OBS_DIR.'aonfm.php');
		$u = $this->get_user_session();
		// tester si proprio du carré
		$ok = false;
		foreach ($u->liste_carre_atlas() as $c) {
			if ($c['id_espace'] == $_GET['id_espace']) {
				$ok = $c['decideur_aonfm'] == 't';
				break;
			}
		}
		if (!$ok) {
			echo "Il faut être responsable du carré <a href=javascript:fermer();>fermer</a>";
			exit();
		}

		if ($u->membre_reseau('av')) {
			$r = new bobs_aonfm_restitution_carre($this->db, $_GET['id_espace'], $_GET['annee']);
			$r->set_resultats_responsables($_GET['id_espece'], $_GET['statut'], $_GET['classe'], $u);
			echo "Ok";
			exit();
		} else {
			echo "Pas enregistré comme membre du réseau avifaune <a href=javascript:fermer();>fermer</a>";
			exit();
		}
		echo 'Erreur inconnue <a href=javascript:fermer();">fermer</a>';
		exit();
	}

	protected function before_atlas_oiseaux_nicheurs_r_espece() {
		require_once(OBS_DIR.'aonfm.php');
		self::cli($_GET['id_espece']);
		$espece = get_espece($this->db, $_GET['id_espece']);
		$this->assign_by_ref('espece', $espece);
		$msgs = array();
		$u = $this->get_user_session();
		// tester si proprio du carré
		$ok = false;
		foreach ($u->liste_carre_atlas() as $c) {
			if ($c['id_espace'] == $_GET['id_espace']) {
				$ok = true;
				$carre = $c;
				break;
			}
		}
		if ($ok) {
			$selection = false;
			// cherche après la sélection
			foreach ($u->selections() as $s) {
				if ("ATLAS-".$carre['nom'] == $s->nom) {
					$selection = $s;
				}
			}
			if (!$selection) {
				$msgs[] = 'Pas trouvé la sélection';
			}
			$this->assign_by_ref('selection_carre', $selection);
			$this->assign_by_ref('id_espece', $_GET['id_espece']);
		} else {
			$msgs[] = "Pas responsable sur ce carré";
		}
		$this->assign_by_ref('carre', $carre);
		$this->assign_by_ref('msgs', $msgs);
		$this->assign_by_ref('t_possible', bobs_aonfm::get_tags_possible());
		$this->assign_by_ref('t_probable', bobs_aonfm::get_tags_probable());
		$this->assign_by_ref('t_certain', bobs_aonfm::get_tags_certains());
		$this->assign('c_possible', bobs_aonfm::couleur_possible);
		$this->assign('c_probable', bobs_aonfm::couleur_probable);
		$this->assign('c_certain', bobs_aonfm::couleur_certain);
	}
	
	protected function before_selections() {
		$u = $this->get_user_session();
		$msgs = array();
		if (array_key_exists('nouvelle_selection',$_POST))
			self::cls($_POST['nouvelle_selection']);
		if (!empty($_POST['nouvelle_selection'])) {
			$nom = htmlentities($_POST['nouvelle_selection'],ENT_COMPAT | ENT_HTML401,'UTF-8');
			$id = $u->selection_creer($nom);
			$msgs[] = "Nouvelle sélection enregistrée <a href='?t=selection&id=$id'>ouvrir</a>";
		}
		$selections_pour_fusion = array();
		foreach (array_keys($_POST) as $k) {
			if (preg_match('/^sel_(\d+)$/', $k, $r)) {
				$selection = $u->selection_get($r[1]);
				if ($selection) {
					switch ($_POST['action']) {
						case 'supprimer':
							$msgs[] = "Sélection <b>{$selection}</b> supprimée.";
							$a = new bobs_selection_supprimer($this->db);
							$a->set('id_selection', $selection->id_selection);
							$a->prepare();
							$a->execute();
							break;
						case 'fusionner':
							$selections_pour_fusion[] = $selection;
							break;
					}
				}
			}	
		}
		if (count($selections_pour_fusion) > 0) {
			$nom = "Fusion de ";
			foreach ($selections_pour_fusion as $sf) {
				$nom .= $sf->__toString()."+";
			}
			$nom = trim($nom,"+");
			$msg = $nom;
			$nom = substr($nom, 0, 250);
			bobs_selection::fusionner($this->db, $u, $nom, $selections_pour_fusion);
		}
		$this->assign_by_ref('msgs', $msgs);
	}

	protected function before_selection_data() {
		$u = $this->get_user_session();
		$s = $u->selection_get($_GET['sel']);
		$page = isset($_GET['page'])?(int)$_GET['page']:0;
		$t = $s->tab_citations(25, $page);
		header('Content-type: application/json');
		echo json_encode($t);
		exit();
	}

	protected function before_selection_action() {
		$u = $this->get_user_session();
		if (isset($_GET['sel']))
			$s = $u->selection_get($_GET['sel']);
		$a = null;
		self::cls($_GET['action']);
		$redirect_liste = false;
		switch ($_GET['action']) {
			case 'vider':
				$a = new bobs_selection_vider($this->db);
				$a->set('id_selection', $s->id_selection);
				break;
			case 'suppr':
				$a = new bobs_selection_supprimer($this->db);
				$a->set('id_selection', $s->id_selection);
				$redirect_liste = true;
				break;
			case 'nicheur':
				//$a = new bobs_selection_extraction_nicheurs($this->db);
				//$a->set('id_selection', $s->id_selection);
				require_once(OBS_DIR.'/taches.php');
				$now = strftime("%Y-%m-%d %H:%M:%S",mktime());
				$tache = clicnat_tache::ajouter($this->db, $now, $_SESSION[SESS]['id_utilisateur'], "Extraction nicheur sélection {$s}", 'clicnat_selection_tr_nicheur', ['id_selection' => $s->id_selection]);
				print_r($tache);
				exit();
				break;
			case 'fusion':
				$s_a = $u->selection_get($_GET['id_selection_a']);
				$s_b = $u->selection_get($_GET['id_selection_b']);
				self::cls($_GET['nom']);
				$a = new bobs_selection_melanger($this->db);
				$a->set('id_selection_a', $s_a->id_selection);
				$a->set('id_selection_b', $s_b->id_selection);
				$a->set('nom', $_GET['nom']);
				$redirect_liste = true;
				break;
			case 'filtrer':
				$s = $u->selection_get($_GET['id_selection']);
				$a = new bobs_selection_filtrer_observateurs($this->db);
				$t_id_utilisateur = array();
				foreach ($_GET as $k=>$v) {
					if (preg_match('/^u_(\d+)$/', $k, $m)) {
						$t_id_utilisateur[] = $m[1];
					}
				}
				$a->set('id_selection', $s->id_selection);
				$a->set('t_id_utilisateur', $t_id_utilisateur);
				break;
			case 'filtrer_selection': // prog validation
				$a = new bobs_selection_filtre_validation($this->db);
				$a->set('id_selection', $s->id_selection);
				break;
			case 'retirer_avec_tag':
				$a = new bobs_selection_enlever_avec_tag($this->db);
				$a->set('id_selection', $s->id_selection);
				$a->set('id_tag', (int)$_GET['id_tag']);
				break;
			case 'retirer_avec_espece':
				$a = new bobs_selection_enlever_avec_espece($this->db);
				$a->set('id_selection', $s->id_selection);
				$a->set('id_espece', (int)$_GET['id_espece']);
				break;
			case 'retirer_avec_classe':
				$a = new bobs_selection_enlever_avec_classe($this->db);
				$a->set('id_selection', $s->id_selection);
				$a->set('classe', $_GET['classe'][0]);
				break;
			case 'retirer_newo':
				$tag = bobs_tags::by_ref($this->db, TAG_NOUVEL_OBSERVATEUR);
				$a = new bobs_selection_enlever_avec_tag($this->db);
				$a->set('id_tag', $tag->id_tag);
				$a->set('id_selection', $s->id_selection);
				break;
			case 'retirer_invalides':
				$tag = bobs_tags::by_ref($this->db, TAG_INVALIDE);
				$a = new bobs_selection_enlever_avec_tag($this->db);
				$a->set('id_tag', $tag->id_tag);
				$a->set('id_selection', $s->id_selection);
				break;
			case 'mix_a':
				$a = new bobs_selection_mix_a($this->db);
				$a->set('projection', (int)$_GET['srid']);
				$a->set('pas', (int)$_GET['pas']);
				$a->set('id_selection', $s->id_selection);
				break;
			case 'filtrer_smax':
				$a = new bobs_selection_filtre_superficie_max($this->db);
				$a->set('id_selection', $s->id_selection);
				$a->set('smax', (int)$_GET['smax']);
				break;
			default:
				throw new Exception('action inconnue');
		}
		if (!empty($a)) {
			$a->prepare();
			$a->execute();
		}
		$_SESSION['msgs'] = $a->messages();
		$this->redirect($redirect_liste?'?t=selections':'?t=selection&sel='.$s->id_selection);
	}

	protected function before_selection() {
		$u = $this->get_user_session();
		if (array_key_exists('id', $_GET))
			$_GET['sel'] = $_GET['id'];
		$s = $u->selection_get($_GET['sel']);
		$this->assign_by_ref('s', $s);
		$this->assign('nav_max', get_config()->query_nv('/clicnat/selections/nb_citations_nav'));
	}

	protected function before_selection_renommer() {
		$u = $this->get_user_session();
		$s = $u->selection_get($_GET['sel']);
		$s->change_nom($_GET['nom']);
		$this->redirect("?t=selection&sel={$_GET['sel']}");
	}

	protected function before_selection_wfs() {
		require_once(OBS_DIR.'wfs.php');
		$data = file_get_contents('php://input'); // contenu de _POST
		$doc = new DomDocument();
		@$doc->loadXML($data);
		header('Content-type: text/xml');
		echo clicnat_wfs_op($this->db, $doc)->reponse()->saveXML();
		exit();
	}

	protected function before_selection_nav() {
		$this->assign('xorg', CLICNAT_X_ORG);
		$this->assign('yorg', CLICNAT_Y_ORG);
		$this->assign('zorg', CLICNAT_Z_ORG);
		$u = $this->get_user_session();
		if (array_key_exists('id', $_GET))
			$_GET['sel'] = $_GET['id'];
		$s = $u->selection_get($_GET['sel']);
		$this->assign_by_ref('s', $s);
	}

	protected function before_selection_datatable() {
		$u = $this->get_user_session();
		if (array_key_exists('id', $_GET))
			$_GET['sel'] = $_GET['id'];
		$s = $u->selection_get($_GET['sel']);
		$rep = $s->get_datatable($_GET);
		echo json_encode($rep);
		exit();
	}

	private function get_d_selection_full($s) {
		return sprintf('/tmp/selection-%d-full', $s->id_selection);
	}

	protected function before_selection_telecharger() {
		$u = $this->get_user_session();
		$s = $u->selection_get($_GET['sel']);

		if (isset($_GET['do'])) {
			switch ($_GET['do']) {
				case 'tache_csv':
					$opts = [];
					if (isset($_GET['xy'])) $opts[bobs_selection::csv_opt_xy] = 1;
					if (isset($_GET['enq']) && !empty($_GET['enq'])) {
						$opts[bobs_selection::csv_opt_enquete] = $_GET['enq'];
					}
					$s->creer_tache_fichier_csv($u, null, $opts);
					$this->redirect('?t=taches');
					break;
				case 'tache_csv_full':
					$s->creer_tache_fichier_csv_full($u);
					$this->redirect('?t=taches');
					break;
				case 'tache_shp':
					$s->creer_tache_fichier_shp($u, null, $_GET['epsg'], isset($_GET['extra_chiro'])?BOBS_EXTRACT_SHP_NCHIRO:BOBS_EXTRACT_SHP_NORMAL);
					$this->redirect('?t=taches');
					break;
				default:
					throw new Exception('action inconnue');
			}
		}

		$f_zip = $this->get_d_selection_full($s).'/'.clicnat_selection_export_full::nom_fichier_zip;
		$this->assign('f_zip', $f_zip);
		$this->assign('zip_ready', file_exists($f_zip));
		$this->assign_by_ref('s', $s);
	}

	protected function before_selection_liste_espece_csv() {
		$u = $this->get_user_session();
		$s = $u->selection_get($_GET['sel']);
		$f = fopen('php://output','w');
		header("Content-Type: text/csv");
		header("Content-Disposition: filename=clicnat_fichiers_{$s->id_selection}.csv");
		$s->liste_especes_csv($f);
		exit();
	}

	protected function before_selection_liste_auteur_csv() {
		$u = $this->get_user_session();
		$s = $u->selection_get($_GET['sel']);
		$f = fopen('php://output','w');
		header("Content-Type: text/csv");
		header("Content-Disposition: filename=clicnat_fichiers_{$s->id_selection}.csv");
		$s->liste_auteurs_csv($f);
		exit();
	}


	protected function before_selection_telecharger_full() {
		$u = $this->get_user_session();
		$s = $u->selection_get($_GET['sel']);

		$dname = $this->get_d_selection_full($s);

		// création du répertoire temporaire

		if (!file_exists($dname)) {
			mkdir($dname);
		}

		$zip = $dname.'/'.clicnat_selection_export_full::nom_fichier_zip;

		if (!file_exists($dname.'/e_create.log') && (!file_exists($zip) || isset($_GET['force']))) {
			touch($dname.'/e_create.log');
			$ex = new clicnat_selection_export_full($this->db);
			$ex->set('chemin', $dname);
			$ex->set('id_selection', $s->id_selection);
			$ex->prepare();
			unlink($dname.'/e_create.log');
			$zip = $ex->execute();
		}

		if (file_exists($zip)) {
			header('Content-Type: application/octet-stream');
			header('Content-Disposition: attachment; filename="'."selection-{$s->id_selection}-full".'.zip"');
			header('Content-Transfer-Encoding: binary');
			echo file_get_contents($zip);
			exit();
		}
		throw new Exception('problème avec export');
	}

	protected function before_selection_telecharger_csv() {
		$u = $this->get_user_session();
		$s = $u->selection_get($_GET['sel']);
		$fh = tmpfile();
		$opts = array();

		if (array_key_exists('toponyme', $_GET))
			$opts['toponyme'] = 1;
		if (array_key_exists('xy', $_GET)) 
			$opts['xy'] = 1;

		if (isset($_GET['enq']) && !empty($_GET['enq'])) {
			$opts[bobs_selection::csv_opt_enquete] = $_GET['enq'];
		}

		$s->extract_csv($fh, $opts);

		$encoding = 'utf8';
		if (!empty($_GET['latin1'])) {
			$encoding = 'latin1';
		}

		header("Content-Type: text/csv");
		header("Content-disposition: filename=clicnat_csv_extraction_{$s->id_selection}_$encoding.csv");

		fseek($fh, 0);
		while (!feof($fh)) {
			if ($encoding != 'utf8')
				echo mb_convert_encoding(fgets($fh), $encoding, 'utf8');
			else
				echo fread($fh, 8192);
		}

		fclose($fh);
		exit();
	}

	protected function before_selection_telecharger_shp() {
		$u = $this->get_user_session();
		$s = $u->selection_get($_GET['sel']);
		$type_extraction = isset($_GET['extra_chiro'])?BOBS_EXTRACT_SHP_NCHIRO:BOBS_EXTRACT_SHP_NORMAL;
		$zip = $s->extract_shp_zip($_GET['epsg_id'], $type_extraction);
		header('content-type: application/octet-stream');
		header('content-disposition: attachment; filename="'."selection-{$s->id_selection}-{$_GET['epsg_id']}".'.zip"');
		header('content-transfer-encoding: binary');
		echo file_get_contents($zip);
		exit();
	}

	protected function before_selection_telecharger_shp_mix() {
		$u = $this->get_user_session();
		$s = $u->selection_get($_GET['sel']);
		$zip = $s->extract_shp_mix_zip($_GET['srid'], $_GET['pas']);
  		header('content-type: application/octet-stream');
		header("content-disposition: attachment; filename=\"selection-{$s->id_selection}-mix-{$_GET['srid']}-{$_GET['pas']}.zip\"");
		header('content-transfer-encoding: binary');
		echo file_get_contents($zip);
		exit();
	}

	protected function before_selection_telecharger_xls() {
		$u = $this->get_user_session();
		$s = $u->selection_get($_GET['sel']);
		$s->extract_xls();
		exit();
	}

	protected function before_selection_open() {
		$id = sprintf("%d", $_GET['id']);
		$s = new bobs_selection($this->db, $id);
		$this->assign_by_ref('s',$s);
	}

	/**
	 * @brief nombre de résultats à partir duquel les espèces sont triées par nombre de citations
	 */
	const especes_n_resultats_tri_n_citations = 17;

	// Prototype (js)
	protected function before_espece_autocomplete() {	
		$u = $this->get_user_session();
		$recherche_vernaculaire = true;
		
		if (preg_match('/sc:? (.*)$/', $_POST['espece'], $res)) {
			$_POST['espece'] = $res[1];
			$recherche_vernaculaire = false;
		}
		
		$_POST['espece'] = str_replace(array('&','"', '(', ')', '@', '+', ':', '.'),' ',$_POST['espece']);
		$_POST['espece'] = self::cls($_POST['espece']);
		
		if (empty($_POST['espece'])) {
			return false;
		}
		
		if ($recherche_vernaculaire) {
			try {
				$especes_v = bobs_espece::recherche_par_nom($this->db, $_POST['espece'],$u->expert);
			} catch (Exception $e) {
				echo "...";
			}
		}
		
		if (!is_array($especes_v))
			$especes_v = array();
		
		$t_obj = bobs_espece::index_recherche($this->db, $_POST['espece']);
		$especes_s = array();

		$ids = array();
		foreach ($especes_v as $e) {
			$ids[] = $e['id_espece'];
		}
		foreach ($t_obj['especes'] as $obj) {
			if (array_search($obj->id_espece, $ids) !== false)
				continue;

			if (!$u->expert && $e->expert) continue;

			$especes_s[] = array(
				'id_espece' => $obj->id_espece,
				'nom_f' => $obj->nom_f,
				'nom_s' => $obj->nom_s, 
				'classe' => $obj->classe, 
				'n_citations' => $obj->n_citations
			);
		}

		$especes = array_merge($especes_v, $especes_s);

		unset($especes_v);
		unset($especes_s);

		if (count($especes) <= self::especes_n_resultats_tri_n_citations) {
			usort($especes, "clicnat_cmp_tri_tableau_especes_n_citations");
		}

		$this->assign_by_ref('rech', $_POST['espece']);
		$this->assign_by_ref('especes', $especes);
	}
 
	// jquery
	protected function before_espece_inpn_autocomplete() {
		bobs_element::cls($_GET['term']);
		require_once(OBS_DIR.'espece.php');
		$r = array();
		$t_obj = bobs_espece_inpn::index_recherche($this->db, $_GET['term']);
		foreach ($t_obj['especes'] as $obj) {
			$r[] = array(
		    		'label'=> "{$obj->lb_nom} <i>{$obj->lb_auteur}</i>", 
				'value' => $obj->cd_nom,
				'classe' => '',
				'n_citations' => 0
			);

		}
		echo json_encode($r);
		exit();
	}

	// jquery
	protected function before_observateur_autocomplete2() {
	    bobs_element::cls($_GET['term']);
	    $t = bobs_utilisateur::rechercher2($this->db, $_GET['term']);
	    $tt = array();
	    if (is_array($t))
		foreach ($t as $l)
		    $tt[] = array('label'=>$l->nom.' '.$l->prenom, 'id'=>$l->id_utilisateur);
	    echo json_encode($tt);
	    exit();
	}
	
	// jquery
	protected function before_tag_citations_autocomplete() {
		bobs_element::cls($_GET['term']);
		$t = bobs_tags::recherche_tag_citation($this->db, $_GET['term']);
		$tt = array();
		if (is_array($t)) 
			foreach ($t as $tag) 
				if (!$tag->categorie_simple) 
					$tt[] = array(
						'label' => $tag->lib,
						'id' => $tag->id_tag,
						'levenshtein' => levenshtein($_GET['term'], $tag->lib)
					);
		function mysort($a,$b) {
			if ($a['levenshtein'] == $b['levenshtein'])
				return 0;
			return $a['levenshtein']>$b['levenshtein']?1:-1;
		}
		usort($tt, 'mysort');
		echo json_encode($tt);
		exit();
	}

	protected function before_observateurs_proche() {
	    $u = $this->get_user_session();
	    $t = $u->observateurs_proche();
	    $tt = array();
	    if (is_array($t))
		foreach ($t as $l)
		    $tt[] = array('label'=>$l->nom.' '.$l->prenom, 'id'=>$l->id_utilisateur);
	    echo json_encode($tt);
	    exit();
	}


	protected function before_chiros() {
		$this->assign('usemap', TRUE);
		$this->assign('gmapon', isset($_GET['sans_google_map'])?'off':'on');
	}

	protected function before_chiro_export_lcav() {
		$u = $this->get_user_session();
		if ($u->acces_chiros) {
			header("Content-Type: text/csv");
			header("Content-disposition: filename=gites_chiros.csv");
			$fname = tempnam('/tmp','exp_chiro');
			$f = fopen($fname, 'w');
			bobs_espace_chiro::tous_avec_tags($this->db, $f);
			fclose($f);
			readfile($fname);
			unlink($fname);
		}
		exit();
	}
	
	protected function before_chiro_espace_detail() {
		$u = $this->get_user_session();
		if ($u->acces_chiros) {
			if (!empty($_GET['ajouter_prospection'])) {
				$espace = get_espace_chiro($this->db, $_GET['id']);
				$tag = bobs_tags::by_ref($this->db, bobs_espace_chiro::tag_prospection);
				$espace->ajoute_tag($tag->id_tag);
			}
			if (!empty($_GET['retirer_prospection'])) {
				$espace = get_espace_chiro($this->db, $_GET['id']);
				$tag = bobs_tags::by_ref($this->db, bobs_espace_chiro::tag_prospection);
				$espace->supprime_tag($tag->id_tag);
			}
			if (!empty($_GET['ajouter_commentaire'])) {
				$espace = get_espace_chiro($this->db, $_GET['id']);
				$espace->ajoute_commentaire('info', $u->id_utilisateur, htmlentities($_GET['commentaire'], ENT_COMPAT|ENT_HTML401, 'UTF-8'));
			}
				}
		$espace = get_espace_chiro($this->db, $_GET['id']);
		$this->assign_by_ref('espace', $espace);
	}

	protected function before_chiro_espace_edit() {
		$u = $this->get_user_session();
		if ($u->acces_chiros) {
		    $espace = get_espace_chiro($this->db, $_GET['id']);
		    $this->assign_by_ref('espace', $espace);
		}
	}

	protected function before_chiro_saisie() {
	    $u = $this->get_user_session();
	    if ($u->acces_chiros) {
		$cavite = get_espace_chiro($this->db, $_GET['id']);
		$this->assign_by_ref('cavite', $cavite);
		$especes = array();
		$liste_especes = array(
		    1049, 3238, 1070,  240,  215,
		     927, 3237, 1069,  211,  702,
		     841,  214, 3297, 1073, 1072,
		    3296,  706,  231,  704,  241,
		     929, 1075,  229, 3236, 1083,
		    1057, 3312,  164
		);
		foreach ($liste_especes as $id)
		    $especes[] = get_espece($this->db, $id);
		$this->assign_by_ref('especes', $especes);
	    }
	}

	protected function before_chiro_espace_sauve() {
		$u = $this->get_user_session();
		$espace = get_espace_chiro($this->db, $_GET['id_espace']);
		$modif = false;
		foreach ($_GET as $k=>$v) {
		    if (preg_match('/^tag_([0-9].*)/', $k, $result)) {
			$id_tag = $result[1];
			if ($espace->a_tag($id_tag)) {
			    $tv = $espace->get_tag($id_tag);
			    // si pas de changement ont passe directement
			    // au suivant.
			    if ($tv['v_text'] == $v)
				continue;
			    $modif = true;
			    $espace->supprime_tag($id_tag);
			    bobs_log("espace_chiro utl={$u->id_utilisateur} espace={$espace->id_espace} tag=$id_tag action=suppr val={$tv['v_text']}");
			}
			if (!empty($v)) {
			    $modif = true;
			    bobs_log("espace_chiro utl={$u->id_utilisateur} espace={$espace->id_espace} tag=$id_tag action=add val=$v");
			    $espace->ajoute_tag($id_tag, null, $v);
			}
		    }
		}
		if ($modif)
		    $espace->date_modif_maj();

		echo "OK";
		exit();
	}

	protected function before_chiro_espace_detail2() {
		$u = $this->get_user_session();		
		if ($u->acces_chiros) {
			$espace = get_espace_chiro($this->db, $_GET['id']);
			switch ($_GET['act']) {
				case 'ajoute_date':
					$_GET['espace_table'] = 'espace_chiro';
					$id = bobs_calendrier::insert($this->db, $_GET);
					$cal = new bobs_calendrier($this->db, $id);
					$cal->ajoute_participant($u->id_utilisateur);
					bobs_log("espace_chiro utl={$u->id_utilisateur} espace={$espace->id_espace} cal=$id action=creation_date");
					break;
				case 'participer':
					$cal = new bobs_calendrier($this->db, $_GET['id_date']);
					$cal->ajoute_participant($u->id_utilisateur);
					bobs_log("espace_chiro utl={$u->id_utilisateur} espace={$espace->id_espace} cal=$id action=participer");
					break;
				case 'annuler':
					$cal = new bobs_calendrier($this->db, $_GET['id_date']);
					$cal->enlever_participant($u->id_utilisateur);
					bobs_log("espace_chiro utl={$u->id_utilisateur} espace={$espace->id_espace} cal=$id action=retirer");
					break;
			}
			$calendriers = $espace->get_calendriers();
			$observations = $espace->get_observations_auth_ok($u->id_utilisateur);
			$this->assign_by_ref('calendriers', $calendriers);
			$this->assign_by_ref('espace', $espace);
			$this->assign_by_ref('observations', $observations);
		}		
	}

	protected function before_chiros_who() {
		$liste = bobs_utilisateur::liste_chiro($this->db);
		$this->assign_by_ref('liste', $liste);
	}

	protected function before_chiros_calendrier() {
		$u = $this->get_user_session();
		if ($u->acces_chiros) {
			if (!empty($_GET['participer'])) {
				$cal = new bobs_calendrier($this->db, $_GET['participer']);
				$cal->ajoute_participant($u->id_utilisateur);
			}
			if (!empty($_GET['annuler'])) {
				$cal = new bobs_calendrier($this->db, $_GET['annuler']);
				$cal->enlever_participant($u->id_utilisateur);
			}
		}
		$liste = bobs_calendrier::get_dates($this->db, 'espace_chiro');
		$this->assign_by_ref('dates', $liste);
	}

	protected function before_chiros_todo() {
		$points = bobs_espace_chiro::get_list_a_prospecter($this->db, true);
		$this->assign_by_ref('points', $points);
	}

	protected function before_chiros_enregistre_point() {
		$u = $this->get_user_session();
		if ($u->acces_chiros) {
		    $data = array(
				'id_utilisateur' => $u->id_utilisateur,
				'reference' => '',
				'nom' => '',
				'x' => $_GET['x'],
				'y' => $_GET['y']
		    );
		    $new_id = bobs_espace_chiro::insert($this->db, $data);
		    bobs_log("espace_chiro utl={$u->id_utilisateur} espace={$new_id} action=creation_espace");
		    echo $new_id;
		    exit();
		} else {
		    throw new Exception('pas membre chiro');
		}
	}

	protected function before_chiro_saisie_enregistre() {
	    if ($this->get_user_session()->acces_chiros) {
			bobs_element::query($this->db, 'begin');
			$date_observation = bobs_element::date_fr2sql($_GET['date_observation']);
			$data = array(
			    'id_espace' => self::cli($_GET['id_espace']),
			    'date_observation' => self::cls($date_observation),
			    'table_espace' => 'espace_chiro',
			    'id_utilisateur' => $this->get_user_session()->id_utilisateur
			);
			if (empty($data['id_utilisateur'])) {
			    throw new Exception('pas sans auteur');
			}
			$id_observation = bobs_observation::insert($this->db, $data);
			echo "Création observation #$id_observation<br/>";
			$observation = new bobs_observation($this->db, $id_observation);
			$u = $this->get_user_session();
			
			$prospection_negative = false;
			$prospection_positive = false;
			
			foreach ($_GET as $k => $id) {
			    if (preg_match('/^u([0-9]*)/', $k, $m)) {
					echo "Ajoute observateur #$id<br/>";
					$observation->add_observateur($id);
			    } else if (($k == 'prospection_negative') && ($id == '1')) { 
			    	// @FIXME référence a une espèce sans configuration
			    	if ($prospection_positive)
			    		throw new Exception('On ne peut pas noter -1 sp si un chiro a été vu');
			    	$prospection_negative = true;
			    	$id_citation = $observation->add_citation(164); // chiro sp
			    	$citation = new bobs_citation($this->db, $id_citation);
			    	$citation->set_effectif(-1);
			    	$u->add_citation_authok($id_citation);
			    } else if (preg_match('/effectif_([0-9]*)/', $k, $m)) {
					$id_espece = $m[1];
					$eff = self::cli($id);
					if ($eff > 0) {
					    echo "Ajoute espèce #$id_espece avec un effectif de $eff<br/>";
					    if ($prospection_negative)
					    	throw new Exception('On ne peut pas noter -1 sp si un chiro a été vu');					    
					    $prospection_positive = true;
					    $id_citation = $observation->add_citation($id_espece);
					    $citation = new bobs_citation($this->db, $id_citation);
					    $citation->set_effectif($eff);
					    $u->add_citation_authok($id_citation);
					}
			    }
			}
			$observation->send();
			bobs_element::query($this->db, 'commit');
			
			exit();
	    } else {
			throw new Exception('pas membre chiro');
	    }
	}

	protected function before_commune_autocomplete() {
		$communes = bobs_espace_commune::rechercher($this->db, Array('nom'=> $_POST['srch_commune']));
		$this->assign_by_ref('communes', $communes);
	}

	protected function before_saisie_base() {
		$u = $this->get_user_session();
		$observation = new bobs_observation($this->db, $_GET['id']);

		if ($u->id_utilisateur != $observation->id_utilisateur) 
			throw new Exception("Vous n'êtes pas l'auteur de cette observation");
		if (!$observation->brouillard) 
			throw new Exception("Cette observation a été envoyée et n'est plus modifiable");

		$this->assign('masque', $_SESSION[SESS]['masque']);
		$this->assign_by_ref('observation', $observation);
		$this->assign_by_ref('s', get_config()->structures_ok_pour_saisie());
		$this->assign_by_ref('p', get_config()->protocoles_en_cours());
	}

	protected function before_saisie_carnet() {
		$u = $this->get_user_session();
		$observation = new bobs_observation($this->db, $_GET['id']);

		if ($u->id_utilisateur != $observation->id_utilisateur) 
			throw new Exception("Vous n'êtes pas l'auteur de cette observation");
		if (!$observation->brouillard) 
			throw new Exception("Cette observation a été envoyée et n'est plus modifiable");

		$this->assign('masque', $_SESSION[SESS]['masque']);
		$this->assign_by_ref('obs', $observation);
	}

	const v_session_structures = 'stuctures';
	const v_session_protocole = 'protocole';

	protected function before_structure_choix_toggle() {
		self::cls($_GET['structure']);

		if (!is_array($_SESSION[SESS][self::v_session_structures]))
			$_SESSION[SESS][self::v_session_structures] = array();

		$pos = array_search($_GET['structure'], $_SESSION[SESS][self::v_session_structures]);
		if ( $pos === false) {
			$_SESSION[SESS][self::v_session_structures][] = $_GET['structure'];
		} else {
			unset($_SESSION[SESS][self::v_session_structures][$pos]);
		}
		exit();
	}

	protected function before_structure_choix_liste() {
		if (!is_array($_SESSION[SESS][self::v_session_structures]))
			$_SESSION[SESS][self::v_session_structures] = array();

		echo json_encode(array_values($_SESSION[SESS][self::v_session_structures]));
		exit();
	}

	protected function before_protocole_set() {
		self::cls($_GET['protocole']);
		if ($_GET['protocole'] == 'aucun')
			$_SESSION[SESS][self::v_session_protocole] = '';
		else
			$_SESSION[SESS][self::v_session_protocole] = $_GET['protocole'];
		exit();
	}

	protected function before_protocole_get() {
		$r = 'aucun';
		if (array_key_exists(self::v_session_protocole, $_SESSION[SESS])) {
			$r = empty($_SESSION[SESS][self::v_session_protocole])?'aucun':$_SESSION[SESS][self::v_session_protocole];
		}
		echo $r;
		exit();
	}

	protected function before_saisie_citation() {
		$u = $this->get_user_session();
		$citation = $u->citation_brouillard($_GET['cid']);
		$this->assign_by_ref('citation', $citation);
	}

	protected function before_saisie_obs_brouillard() {
	}


	protected function before_saisie_citation_editeur_tags() {
		$u = $this->get_user_session();
		$citation = $u->citation_brouillard($_GET['id']);
		$this->assign_by_ref('citation', $citation);
	}

	protected function before_saisie_citation_editeur() {
		$liste_principaux_codes = array(
		    '1000','5000','5500','5100','4000','1150','2100','2200','9120','1300',
		    '2202','2210','3005','3010','3011','3012','3013','3014',
		    '3020','3030','3031','1306','3033','3110','3111','3112',
		    '3113','3114','3115','3116','3120','3121','3122','3140',
		    '3150','3160','3170','3200','3210','3310','3320','3330',
		);
		$u = $this->get_user_session();
		$citation = $u->citation_brouillard($_GET['id']);
		if ($citation->get_espece()->classe == 'M') {
			$chiros = array('CHIV','CEST','CSWA','DTRA','CDEC','DCHA');
			$liste_principaux_codes = array_merge($liste_principaux_codes, $chiros);
		} else if ($citation->get_espece()->classe == 'O') {
			$liste_principaux_codes = array_merge($liste_principaux_codes, array('9610','9101'));
		}
		$principaux = array();

		foreach ($liste_principaux_codes as $code) {
			try {
				$principaux[] = bobs_tags::by_ref($this->db, $code);
			} catch (Exception $e) {
				echo "<font color=red>$code est un tag non référencé</font><br/>";
			}
		}
		require_once(OBS_DIR.'enquetes.php');
		$enquetes = clicnat_enquete::enquetes_espece_derniere_version($this->db, $citation->id_espece);
		if (count($enquetes) >=1 ) {
			$this->assign_by_ref('enquete', $enquetes[0]);
		}
		$this->assign_by_ref('citation', $citation);
		$this->assign_by_ref('principaux_codes', $principaux);
	}

	protected function before_saisie_dupliquer() {
		$u = $this->get_user_session();
		$obs = $u->observation_brouillard($_GET['id']);
		$date = bobs_element::date_fr2sql($_GET['date']);
		$newid = $obs->dupliquer($date);
		$this->redirect('?t=saisie_base&id='.$newid);
		exit();
	}

	protected function before_graphique_citations_chanteurs() {
		$espece = get_espece($this->db, $_GET['id']);
		$this->assign_by_ref('espece', $espece);
		$output = $this->fetch('gnuplot/citations_nicheurs.plot');
		$f_plotscript = tempnam("/tmp", "plot");
		
		file_put_contents($f_plotscript, $output);
		
		shell_exec('/usr/bin/gnuplot '.$f_plotscript.' > '.$f_plotscript.'.png');
		header("Content-Type: image/png");
		readfile($f_plotscript.'.png');
		unlink($f_plotscript);
		unlink($f_plotscript.'.png');
		exit();
	}

	protected function before_saisie() {
		$u = $this->get_user_session();
		$_SESSION[SESS]['masque'] = 'saisie';
		$this->assign('usemap', true);
		$this->assign('xorg', CLICNAT_X_ORG);
		$this->assign('yorg', CLICNAT_Y_ORG);
		$this->assign('zorg', CLICNAT_Z_ORG);
		$this->assign('x', $u->session_var_get(BOBS_POSTE_VS_X));
		$this->assign('y', $u->session_var_get(BOBS_POSTE_VS_Y));
		$this->assign('z', $u->session_var_get(BOBS_POSTE_VS_Z));

		$this->assign('date_derniere_saisie', array_key_exists('date_derniere_saisie', $_SESSION[SESS])?$_SESSION[SESS]['date_derniere_saisie']:'');

	}

	public function before_chiros_recherche_espace() {
		try {
				self::cls($_GET['ref_point']);
				$u = $this->get_user_session();
				if ($u->acces_chiros_ok()) {
					bobs_element::cls($_GET['ref_point']);
					$espace = bobs_espace_chiro::get_by_ref($this->db, $_GET['ref_point']);
					if (!$espace) {
						$data = array('err' => 1, 'message' => 'pas trouvé');
					} else {
						$data = array(
							'id_espace' => $espace->id_espace,
							'ref' => $espace->reference,
							'wkt' => $espace->get_geom(),
							'x' => $espace->get_x(),
							'y' => $espace->get_y()
						);
					}
				} else {
					$data = array('err' => 1, 'message' => 'pas autorisé');
				}
		} catch (Exception $e) {
			$data = array('err' => 1, 'message' => $e->getMessage());
		}
		echo json_encode($data);
		exit();
	}

	public function before_espace_get_geom() {
		bobs_element::cls($_GET['espace_table']);
		bobs_element::cli($_GET['id_espace']);
		$autorise = false;
		switch ($_GET['espace_table']) {
			case 'espace_chiro':
				$u = $this->get_user_session();
				$autorise = $u->acces_chiros_ok();
				if ($autorise)
					$espace = get_espace_chiro($this->db, $_GET['id_espace']); 
				break;
			case 'espace_point':
				$autorise = true;
				$espace = get_espace_point($this->db, $_GET['id_espace']);
				break;
			case 'espace_polygon':
				$autorise = true;
				$espace = new bobs_espace_polygon($this->db, $_GET['id_espace']);
				break;
			case 'espace_line':
				$autorise = true;
				$espace = new bobs_espace_ligne($this->db, $_GET['id_espace']);
				break;

		}
		
		if (!$autorise) {
			exit();
		}
		
		if (isset($espace)) {
			echo $espace->get_geom();
		}
		exit();
	}

	protected function before_commune_gml() {
		header('Content-type: text/xml');
		$commune = get_espace_commune($this->db, $_GET['id']);
		echo '<clicnat xmlns:gml="http://www.opengis.net/gml">';
		echo $commune->get_geom_gml();
		echo "</clicnat>";
		exit();
	}

	protected function before_json() {
		try {
			self::cls($_GET['a']);
			if (empty($_GET['a'])) throw new Exception('Pas d\'action');

			$u = $this->get_user_session();

			switch($_GET['a']) {
				case 'gender_list':
					$this->header_cacheable(86400);
					$this->header_json();
					$liste = bobs_citation::get_gender_list();
					$this->assign('data', json_encode($liste));
					break;
				case 'age_list':
					$this->header_cacheable(86400);
					$this->header_json();
					$liste = bobs_citation::get_age_list();
					$this->assign('data', json_encode($liste));
					break;
				case 'espace_ajouter_commentaire':
					$espace = get_espace($this->db, $_GET['table'],$_GET['id_espace']);
					$espace->ajoute_commentaire('info', $u->id_utilisateur, self::cls($_GET['commentaire'], bobs_tests::except_si_vide));
					$this->assign('data', "ok");
					break;
				case 'espace_commentaires':
					$commentaires_brut = get_espace($this->db, $_GET['table'], $_GET['id_espace'])->get_commentaires();
					$commentaires = array();
					foreach ($commentaires_brut as $c) {
						$commentaires[] = array(
							"utilisateur" => $c->utilisateur->__toString(),
							"commentaire" => $c->commentaire,
							"date_commentaire_fr" => $c->date_commentaire_f,
							"date" => $c->date_commentaire
						);
					}
					$this->assign('data', json_encode($commentaires));
					break;
				case 'calendrier_ajoute_date':
					require_once(OBS_DIR.'calendriers.php');
					$data = array(
						'id_espace' => (int)$_GET['id_espace'],
						'espace_table' => $_GET['espace_table'],
						'date_sortie' => $_GET['date_sortie'],
						'tag' => $_GET['tag']
					);
					$id = bobs_calendrier::insert($this->db, $data);
					$this->assign('data', $id);
					break;
				case 'calendrier_maj_date':
					require_once(OBS_DIR.'calendriers.php');
					$calendrier = new bobs_calendrier($this->db, (int)$_GET['id_date']);
					$t = explode(',', $_GET['participants']);
					$calendrier->sync_liste_participants($t);
					$calendrier->update_commentaire($_GET['commentaire']);
					$this->assign('data', json_encode(array('err'=>0)));
					break;
				case 'calendrier_date':
					require_once(OBS_DIR.'calendriers.php');
					$calendrier = new bobs_calendrier($this->db, (int)$_GET['id_date']);
					$participants = $calendrier->get_participants();
					$data = array(
						'id_date' => $calendrier->id_date,
						'date_sortie' => $calendrier->date_sortie,
						'participants' => $participants,
						'commentaire' => $calendrier->commentaire,
						'espace_table' => $calendrier->espace_table,
						'id_espace' => $calendrier->id_espace,
						'tag' => $calendrier->tag,
						'xy' =>  $calendrier->get_espace()->get_centroid()
					);
					$this->assign('data', json_encode($data));
					break;
				case 'calendrier_annuler_date':
					$calendrier = new bobs_calendrier($this->db, (int)$_GET['id_date']);
					$calendrier->annuler();
					break;
				case 'tag':
					$tag = new bobs_tags($this->db, $_GET['id']);
					$data = array(
						'id_tag' => $tag->id_tag,
						'parent_id' => $tag->parent_id,
						'lib' => $tag->lib,
						'ref' => $tag->ref,
						'a_chaine' => $tag->a_chaine == 't',
						'a_entier' => $tag->a_entier == 't',
						'categorie_simple' => $tag->categorie_simple
					);
					$this->assign('data', json_encode($data));
					break;
				case 'observation':
					$u = $this->get_user_session();
					$o = new bobs_observation($this->db, $_GET['id']);
					if (!$o->id_observation) 
						throw new Exception("problème de chargement ido:{$o->id_observation}");
					if ($u->id_utilisateur != $o->id_utilisateur)
						throw new Exception('pas auteur');

					$data = array(
						'id_observation' => $o->id_observation,
						'id_utilisateur' => $o->id_utilisateur,
						'espace_table' => $o->espace_table,
						'brouillard' => $o->brouillard == 't',
						'date_observation' => $o->date_observation,
						'heure_observation' => $o->heure_observation,
						'duree_observation' => $o->duree_observation,
						'localisation' => $o->get_espace()->__toString(),
						'observateurs' => $o->get_observateurs(),
						'citations_ids' => $o->get_citations_ids()
					);
					$this->assign('data', json_encode($data));
					break;
				case 'observation_commentaires':
					$u = $this->get_user_session();
					$observation = get_observation($this->db, $_GET['id_observation']);
					if ($u->id_utilisateur != $observation->id_utilisateur)
						throw new Exception('pas auteur');
					if (isset($_GET['ajouter_commentaire'])) {
						$observation->ajoute_commentaire('info', $u->id_utilisateur, htmlentities($_GET['ajouter_commentaire'], ENT_QUOTES, 'UTF-8'));
					}
					foreach ($observation->get_commentaires() as $c) {
						echo "<div class=bobs-commtr-obs>{$c->commentaire}</div>\n";
					}
					break;
				case 'observation_set_liste_observateurs':
					// arguments : 
					//  $_GET['id'] : numéro de l'observation
					//  $_GET['observateurs'] : chaine de caractere avec les numéro d'utilisateurs
					//    exemple : "123,124,125"
					$u = $this->get_user_session();
					$obs_obj = new bobs_observation($this->db, $_GET['id']);
					$data = array('ajoute'=>array(),'enleve'=>array());
					if (!$obs_obj->id_observation) 
						throw new Exception("problème de chargement ido:{$obs_obj->id_observation}");
					if ($u->id_utilisateur != $obs_obj->id_utilisateur)
						throw new Exception('pas auteur');

					$obs_obs = array();
					$msg = '';
					foreach ($obs_obj->get_observateurs() as $o) {
						$obs_obs[] = $o['id_utilisateur'];
					}

					$obs_new = explode(',', $_GET['observateurs']);
					foreach ($obs_new as $o) {
						if (array_search($o, $obs_obs) === false) {
							$obs_obj->add_observateur($o);
							$data['ajoute'][] = $o;
							$msg.="+{$o}";
						}
					}
					foreach ($obs_obj->get_observateurs() as $o) {
						if (array_search($o['id_utilisateur'], $obs_new) === false) {
							$data['enleve'][] = $o['id_utilisateur'];
							$msg.="-{$o['id_utilisateur']}";
							$obs_obj->del_observateur($o['id_utilisateur']);
						}
					}
					$data['message'] = $msg;
					$this->assign('data', json_encode($data));
					break;
				case 'observation_ajoute_observateur':
					$observation = $u->observation_brouillard($_GET['id']);
					$observation->add_observateur($_GET['id_observateur']);
					$data['observateurs'] = $observation->get_observateurs();
					$this->assign('data', json_encode($data));
					break;
				case 'observation_supprime_observateur':
					$observation = $u->observation_brouillard($_GET['id']);
					$observation->del_observateur($_GET['id_observateur']);
					$data['observateurs'] = $observation->get_observateurs();
					$this->assign('data', json_encode($data));
					break;
				case 'observation_observateurs':
					$observation = $u->observation_brouillard($_GET['id']);
					$data['observateurs'] = $observation->get_observateurs();
					$this->assign('data', json_encode($data));
					break;
				case 'citation':
					$u = $this->get_user_session();
					$c = $u->get_citation_authok($_GET['id']);
					$e = $c->get_espece();
					$data = array(
						'id_citation' => $c->id_citation,
						'id_espece' => $c->id_espece,
						'nom' => $e->__toString(),
						'nom_s' => $e->nom_s,
						'nom_f' => $e->nom_f,
						'tags' => $c->get_tags()
					);
					$this->assign('data', json_encode($data));
					break;
				case 'selection_creer':
					$u->selection_creer($_GET['nom']);
					break;
				case 'selection_liste':
					$s = $u->selections();
					$this->assign('data', json_encode($s));
					break;
				case 'selection_retirer':
					$id_citation = sprintf("%d", $_GET['citation']);
					$id_selection = sprintf("%d", $_GET['selection']);
					$selection = $u->selection_get($id_selection);
					$selection->enlever($id_citation);
					$this->assign('data', $id_citation);
					break;
				case 'espace_chiros_in':
					$data = array();
					foreach (array('ax','ay','bx','by') as $col) {
						if (empty($_GET[$col]))
						    throw new Exception('$_GET['.$col.'] manquant');
						$data[] = $_GET[$col];
					}
					$json = bobs_espace_chiro::get_espaces_in_box_geojson($this->db, $data, 'espace_chiro');
					$this->assign_by_ref('data', $json);
					break;
				case 'commune':
					bobs_element::cli($_GET['id']);
					$commune = new bobs_espace_commune($this->db, $_GET['id']);
					$json = $commune->get_json();
					$this->assign_by_ref('data', $json);
					break;
				case 'point_info':
					$c = bobs_espace_commune::get_commune_for_point($this->db, $_GET['wkt']);
					$src = 'Commune';
					$topos = array();
					if (!is_array($c)) {
						$c = bobs_espace_littoral::get_littoral_for_point($this->db, $_GET['wkt']);
						if (is_array($c))
							$src = 'Littoral';
						else
							$src = 'Hors limites...';
					} else {
						$zu = bobs_espace_toponyme::point_dans_zone_urbaine_dense($this->db, $_GET['wkt'], 4326);
						if (!$zu)
							$topos = bobs_espace_toponyme::a_proximite_wkt($this->db, $_GET['wkt'], 4326);
					}
					$retour = sprintf('%s<br/>&nbsp;&nbsp;<font color="red">%s</font>', $src, $c['nom']);
					if (count($topos) > 0) {
						$retour .= "<br/>Toponyme le plus proche :<br/><b>{$topos[0]->nom}</b>";
					}
					if ($zu) {
						$retour .= '<br/><b>Point dans zone urbaine</b>';
					}
					$this->assign_by_ref('data', $retour);
					break;
				case 'creation_observation':
					bobs_observation::cls($_GET['date']);
					bobs_observation::cli($_GET['id_espace'], false);
					bobs_observation::cls($_GET['table_espace'], false);

					$u = $this->get_user_session();
					if (isset($_GET['x'])) $u->session_var_save(BOBS_POSTE_VS_X, $_GET['x']);
					if (isset($_GET['y'])) $u->session_var_save(BOBS_POSTE_VS_Y, $_GET['y']);
					if (isset($_GET['zoom'])) $u->session_var_save(BOBS_POSTE_VS_Z, $_GET['zoom']);

					if (empty($_GET['date'])) {
						$this->assign('data', 'DATE_VIDE');
						break;
					}

					$date_obs = bobs_observation::date_fr2sql($_GET['date']);
					$_SESSION[SESS]['date_derniere_saisie'] = $_GET['date'];

					if (empty($_GET['id_espace'])) {
						/*if (empty($_GET['x']) or empty($_GET['y'])) {
							$this->assign('data', 'NOPOINT');
							break;
						}*/
						if (array_key_exists('x', $_GET) && array_key_exists('y', $_GET)) {
							$id_espace = bobs_espace_point::insert($this->db, array(
								'id_utilisateur' => $_SESSION[SESS]['id_utilisateur'],
								'nom' => array_key_exists('nom', $_GET)?$_GET['nom']:'',
								'reference' => null,
								'x' => $_GET['x'],
								'y' => $_GET['y']
							));
							$table_espace = 'espace_point';
						} else if (array_key_exists('geojson', $_GET)) {
							$table_espace = 'espace_polygon';
							$id_espace = bobs_espace_polygon::insert_wkt($this->db, array(
								'id_utilisateur' => $_SESSION[SESS]['id_utilisateur'],
								'nom' => $_GET['nom'],
								'reference' => null,
								'wkt' => bobs_espace_polygon::wkt_depuis_geojson($_GET['geojson'])
							));
						}
					} else {
						$id_espace = $_GET['id_espace'];
						$table_espace = $_GET['table_espace'];
					}
					$id_obs = bobs_observation::insert($this->db, array(
						'id_utilisateur' => $_SESSION[SESS]['id_utilisateur'],
						'date_observation' => $date_obs,
						'id_espace' => $id_espace,
						'table_espace' => $table_espace
					));
					$obs = new bobs_observation($this->db, $id_obs);
					$obs->add_observateur($u->id_utilisateur);
					$this->assign('data', $id_obs);
					break;
				case 'ajouter_supprimer_tag_citation':
					$u = $this->get_user_session();
					$citation = $u->citation_brouillard($_GET['cid']);
					$tag = new bobs_tags($this->db, $_GET['tid']);
					if ($citation->a_tag($_GET['tid'])) {
						$citation->supprime_tag($_GET['tid']);
						$data = array(
							'id_citation' => $_GET['cid'],
							'id_tag' => $_GET['tid'],
							'statut' => 'absent',
							'lib' => $tag->lib
						);
					} else {
						$citation->ajoute_tag($_GET['tid']);
						$data = array(
							'id_citation' => $_GET['cid'],
							'id_tag' => $_GET['tid'],
							'statut' => 'present',
							'lib' => $tag->lib
						);
					}
					$this->assign('data', json_encode($data));
					break;
				case 'ajouter_tag_citation':
					$u = $this->get_user_session();
					$citation = $u->citation_brouillard($_GET['cid']);
					if (!$citation->a_tag($_GET['tid']))
					$citation->ajoute_tag($_GET['tid']);
					$this->assign('data', 'OK');
					break;
				case 'supprimer_tag_citation':
					$u = $this->get_user_session();
					$citation = $u->citation_brouillard($_GET['cid']);
					if ($citation->a_tag($_GET['tid']))
					$citation->supprime_tag($_GET['tid']);
					$this->assign('data', 'OK');
					break;
				case 'creer_citation':
					$u = $this->get_user_session();
					$observation = $u->observation_brouillard($_GET['oid']);
					$id_citation = $observation->add_citation($_GET['id']);
					$u->add_citation_authok($id_citation);
					if (array_key_exists(self::v_session_structures, $_SESSION[SESS])) {
						if (count($_SESSION[SESS][self::v_session_structures]) > 0) {
							$c = get_citation($this->db, $id_citation);
							foreach ($_SESSION[SESS][self::v_session_structures] as $struct) {
								$c->ajouter_dans_structure($struct,$u->id_utilisateur);
							}
						}
					}
					if (array_key_exists(self::v_session_protocole, $_SESSION[SESS])) {
						if (!empty($_SESSION[SESS][self::v_session_protocole])) {
							$c = get_citation($this->db, $id_citation);
							$c->ajouter_dans_protocole($_SESSION[SESS][self::v_session_protocole], $u->id_utilisateur);
						}
					}
					$this->assign('data', $id_citation);
					break;
				case 'supprimer_citation':
					$u = $this->get_user_session();
					$citation = $u->citation_brouillard($_GET['cid']);
					$citation->delete();
					$this->assign('data', $citation->id_citation);
					break;
				case 'supprimer_observation':
					$u = $this->get_user_session();
					$observation = $u->observation_brouillard($_GET['oid']);
					$observation->delete();
					$this->assign('data', 'OK');
					break;
				case 'citation_formulaire_part1':
					$u = $this->get_user_session();
					$citation = $u->citation_brouillard($_GET['cid']);
					$citation->set_effectif($_GET['effectif']);
					if ((!empty($_GET['nb_min'])) && (!empty($_GET['nb_max']))||($_GET['nb_min']=='0')) {
						$citation->set_effectif_min_max($_GET['nb_min'], $_GET['nb_max']);
					}
					$citation->set_sex($_GET['sexe']);
					$citation->set_age($_GET['age']);
					$citation->set_indice_qualite($_GET['indice_qualite']);
					$this->assign('data', $citation->id_citation);
					break;
				case 'citation_formulaire_enquete':
					require_once(OBS_DIR.'/enquetes.php');
					$enquete = new clicnat_enquete($this->db, (int)$_GET['id_enquete']);
					$enquete_v = $enquete->version((int)$_GET['version']);
					$u = $this->get_user_session();
					$citation = $u->citation_brouillard((int)$_GET['id_citation']);
					$doc_xml = $enquete_v->resultat_enregistre($citation->id_citation, $_GET);
					$citation->set_enquete_resultat($doc_xml);
					$this->assign('data', $citation->id_citation);
					break;
				case 'citation_formulaire_commentaire':
					$u = $this->get_user_session();
					$citation = $u->citation_brouillard($_GET['cid']);
					$citation->set_commentaire($_GET['commentaire']);
					$this->assign('data', $citation->id_citation);
					break;
				case 'observation_x_y':
					$u = $this->get_user_session();
					$observation = $u->observation_brouillard($_GET['oid']);
					$espace = $observation->get_espace();
					$pt = array(
						'x' => $espace->get_x(), 
						'y' => $espace->get_y(),
						'id_espace' => $espace->id_espace,
						'table_espace' => $espace->get_table()
					);
					$this->assign('data', json_encode($pt));
					break;
				case 'observation_valider':
					$u = $this->get_user_session();
					$observation = $u->observation_brouillard($_GET['oid']);
					$observation->send();
					$this->assign('data', 'OK');
					break;
				case 'observation_heure_duree':
					$u = $this->get_user_session();
					$observation = $u->observation_brouillard($_GET['oid']);
					$observation->set_heure($_GET['h_h'], $_GET['h_m'], $_GET['h_s']);
					$observation->set_duree($_GET['d_h'], $_GET['d_m'], $_GET['d_s']);
					$this->assign('data', 'OK');
					break;
				default:
					throw new Exception("Action {$_GET['a']} pas dans la liste");
			}
		} catch (Exception $e) {
			$data = array('err' => 1, 'message' => $e->getMessage());
			$this->assign('data', json_encode($data));
		}
	}
	
	protected function before_avifaune_n_jours_commune() {
		$commune = get_espace_commune($this->db, $_GET['id']);
		if (!$commune) throw new Exception('Commune inconnue');
		$this->assign_by_ref('commune', $commune);
		$ex = new bobs_extractions($this->db);
		$ex->ajouter_condition(new bobs_ext_c_classe('O'));
		$ex->ajouter_condition(new bobs_ext_c_interval_date(strftime('%d/%m/%Y', mktime()-86400*10), strftime('%d/%m/%Y',mktime())));
		$ex->ajouter_condition(new bobs_ext_c_commune($_GET['id']));
		$this->assign_by_ref('citations', $ex->get_citations());
	}

	protected function before_pap_n_jours_commune() {
		$commune = get_espace_commune($this->db, $_GET['id']);
		if (!$commune) throw new Exception('Commune inconnue');
		$this->assign_by_ref('commune', $commune);
		$ex = new bobs_extractions($this->db);
		$ex->ajouter_condition(new critere_reseau_papillon());
		$ex->ajouter_condition(new bobs_ext_c_interval_date(strftime('%d/%m/%Y', mktime()-86400*10), strftime('%d/%m/%Y',mktime())));
		$ex->ajouter_condition(new bobs_ext_c_commune($_GET['id']));
		$this->assign_by_ref('citations', $ex->get_citations());
	}

	protected function before_reseau_n_jours_commune() {
		$u = $this->get_user_session();

		if (!isset($_GET['reseau']))
			throw new Exception('Précisez un réseau');

		if (!$u->membre_reseau($_GET['reseau']))
			throw new Exception("Pas membre du réseau");

		$reseau = new bobs_reseau($this->db, $_GET['reseau']);
		$this->assign_by_ref('reseau', $reseau);

		$commune = get_espace_commune($this->db, $_GET['id']);

		if (!$commune)
			throw new Exception('Commune inconnue');

		$this->assign_by_ref('commune', $commune);
		
		$ex = new bobs_extractions($this->db);
		$ex->ajouter_condition(new bobs_ext_c_reseau($reseau));
		$ex->ajouter_condition(new bobs_ext_c_interval_date(strftime('%d/%m/%Y', mktime()-86400*$reseau->restitution_nombre_jours), strftime('%d/%m/%Y',mktime())));
		$ex->ajouter_condition(new bobs_ext_c_commune($_GET['id']));
		$this->assign_by_ref('e', $ex);
		$this->assign_by_ref('citations', $ex->get_citations());
	}
	
	protected function before_reseau_n_jours_espece() {
		$u = $this->get_user_session();
	
		if (!isset($_GET['reseau']))
			throw new Exception('Précisez un réseau');
		$reseau = new bobs_reseau($this->db, $_GET['reseau']);

		if (!$u->membre_reseau($_GET['reseau']))
			throw new Exception("Pas membre du réseau");

		$espece = get_espece($this->db, $_GET['id']);

		if (!$espece) 
			throw new Exception('Espèce inconnue');

		$this->assign_by_ref('espece', $espece);
		$ex = new bobs_extractions($this->db);
		$ex->ajouter_condition(new bobs_ext_c_reseau($reseau));
		$ex->ajouter_condition(new bobs_ext_c_interval_date(strftime('%d/%m/%Y', mktime()-86400*$reseau->restitution_nombre_jours), strftime('%d/%m/%Y',mktime())));
		$ex->ajouter_condition(new bobs_ext_c_espece($_GET['id']));
		$this->assign_by_ref('citations', $ex->get_citations());
	}

	protected function before_avifaune_n_jours_espece() {
		$espece = get_espece($this->db, $_GET['id']);
		if (!$espece) throw new Exception('Espèce inconnue');
		$this->assign_by_ref('espece', $espece);
		$ex = new bobs_extractions($this->db);
		$ex->ajouter_condition(new bobs_ext_c_classe('O'));
		$ex->ajouter_condition(new bobs_ext_c_interval_date(strftime('%d/%m/%Y', mktime()-86400*10), strftime('%d/%m/%Y',mktime())));
		$ex->ajouter_condition(new bobs_ext_c_espece($_GET['id']));
		$this->assign_by_ref('citations', $ex->get_citations());
	}

	protected function before_pap_n_jours_espece() {
		$espece = get_espece($this->db, $_GET['id']);
		if (!$espece) throw new Exception('Espèce inconnue');
		$this->assign_by_ref('espece', $espece);
		$ex = new bobs_extractions($this->db);
		$ex->ajouter_condition(new critere_reseau_papillon());
		$ex->ajouter_condition(new bobs_ext_c_interval_date(strftime('%d/%m/%Y', mktime()-86400*10), strftime('%d/%m/%Y',mktime())));
		$ex->ajouter_condition(new bobs_ext_c_espece($_GET['id']));
		$this->assign_by_ref('citations', $ex->get_citations());
	}

	protected function before_info_carre_atlas() {
		self::cls($_GET['carre']);

		if (empty($_GET['carre']))
		throw new InvalidArgumentException('nom carré ?');

		$espace = bobs_espace_l93_10x10::get_by_nom($this->db, $_GET['carre']);
		$this->assign_by_ref('espace', $espace);

		$this->assign('voir_nicheur', isset($_GET['voir_nicheur']));
	}

	private function map_extract($width, $height) {
		global $disallow_dump ;
		$disallow_dump = true;
		bobs_element::cls($_GET['class'], true);
		bobs_element::cls($_GET['fond']);

		if (!in_array($_GET['fond'], array('scan25','scan100', 'scan1000', 'ortho')))
		throw new Exception('unknown layer');

		switch ($_GET['class']) {
			case 'commune':
				$obj = new bobs_espace_commune($this->db, $_GET['id']);
				break;
			default:
				throw new Exception('unknown class');
		}
		$img = $obj->get_ms_img($width, $height, $_GET['fond']);
		if (!$img)
		throw new Exception('get_ms_img failed');
		bobmap_image_out($img);
	}

	private function espace_vignette($espace) {
		$commune = $espace->get_commune();
		$p = bobmap_point_reproject($espace->get_x(), $espace->get_y());
		$img = $commune->get_ms_img(400, 300, 'scan100', $p);
		bobmap_image_out($img);
	}

	/**
	 * @todo ajouter un test point
	 * @todo verifier le droit a voir la vignette
	 */
	protected function before_obs_vignette() {
		if (!$this->authok()) throw new ExceptionErrAuth();
		$obs = new bobs_observation($this->db, $_GET['id']);
		$this->espace_vignette($obs->get_espace());
	}

	protected function before_espace_chiro_vignette() {
		$u = $this->get_user_session();
		if ($u->acces_chiros) {
			$point = get_espace_chiro($this->db, $_GET['id']);
			$this->espace_vignette($point);
		}
	}


	protected function before_atlas() {
		if (!$this->authok()) throw new ExceptionErrAuth();
		$espece = get_espece($this->db, $_GET['id']);
		if ($espece->get_atlas())
		$atlas = $espece->get_atlas_img();
		else
		throw new Exception('no atlas for this id');
		exit(0);
	}

	protected function before_especes() {
		if (array_key_exists('r_objet', $_GET))
			$this->assign('r_objet', $_GET['r_objet']);

		if (array_key_exists('r_ref', $_GET))
			$this->assign('r_ref', $_GET['r_ref']);

		if (!empty($_GET['objet'])) {
			$this->assign('objet', $_GET['objet']);

			switch ($_GET['objet']) {
				case 'classes':
					break;
				case 'classe':
					self::cls($_GET['ref']);

					if (strlen($_GET['ref'])>1)
						throw new Exception('class invalid');

					if (empty($_GET['ref']))
						throw new Exception('ref is empty');

					$this->assign('classe_lib', bobs_espece::get_classe_lib_par_lettre($_GET['ref']));
					$ordres = bobs_espece::get_ordres_for_classe($this->db, $_GET['ref']);
					$this->assign_by_ref('ordres', $ordres);
					break;
				case 'ordre':
					self::cls($_GET['ref']);
					$l_especes = bobs_espece::get_especes_for_ordre_classe($this->db, $_GET['ref']);
					$especes = new clicnat_iterateur_especes($this->db, array_column($l_especes, 'id_espece'));

					$this->assign_by_ref('especes', $especes);
					$this->assign_by_ref('ordre_lib', $l_especes[0]['ordre']);
					$this->assign_by_ref('classe', $l_especes[0]['classe']);
					$this->assign_by_ref('classe_lib', bobs_espece::get_classe_lib_par_lettre($l_especes[0]['classe']));
					break;
			}
		}
	}
	
	public function before_structure_referentiel_espece() {
		// FIXME compte structure
		require_once(OBS_DIR.'referentiel_tiers.php');
		$u = $this->get_user_session();
		switch ($u->id_utilisateur) {
			case 2033: $structure = 'dreal'; break;
			case 849: $structure = 'dreal'; break;
			case 2096: $structure = 'cenp'; break;
			case 2093: $structure = 'cenp'; break;
			default:
				throw new Exception('pas dans une structure ?');
		}
		$ref = new bobs_referentiel_especes_tiers($this->db, $structure);
		if (!empty($_GET['act'])) {
			switch ($_GET['act']) {
				case 'ajout':
					$ref->ajoute($_POST['id_espece'], $_POST['id_tiers']);					
					break;
				case 'retirer':
					$ref->supprime_reference_tiers($_GET['id_tiers']);
					break;
				case 'telecharger':
					header("Content-Type: text/csv");
					header("Content-disposition: filename=referentiel_{$ref->nom}.csv");
					echo $ref->ligne_referentiel_csv_titres();
					foreach ($ref->get_referentiel() as $l) {						
						echo iconv('utf8','latin1',$ref->ligne_referentiel_csv($l));
					}
					exit();
					break;
				default:
					throw new Exception('action inconnue');
			}
			$this->redirect('?t=structure_referentiel_espece');
		} else {
			$this->assign_by_ref('ref', $ref);
		}
	}
	
	protected function before_espece_deplacer() {
		self::cli($_GET['id']);
		$orig = get_espece($this->db, $_GET['id']);
	}
	
	protected function before_reglement() {
		$u = $this->get_user_session();
		if (!$u->agreed_the_rules()) {
			if (!empty($_POST['accept'])) {
				$u->accept_rules($_POST['d_restreintes']);
				$u = new bobs_utilisateur($this->db, $u->id_utilisateur);
				$_SESSION[SESS]['id_utilisateur'] = $u->id_utilisateur;
				$_SESSION[SESS]['utilisateur'] = serialize($u);
				$this->redirect('?t=accueil');
			}
		}
		// raffraichissement
		$u = $this->get_user_session();
		$this->assign('u', $u);
	}
	
	public function before_citation_detail() {
		$u = $this->get_user_session();
		$citation =  $u->get_citation_authok($_GET['id']);
		$this->assign_by_ref('citation', $citation);
	}
	
	public function before_citation_liste_commentaires() {
		return $this->before_citation_detail();
	}

	public function before_citation_filtrage() {
		$u = $this->get_user_session();
		$citation_org =  $u->get_citation_authok($_GET['id']);
		$citation_validation= new bobs_citation_avec_validation($this->db,$citation_org->id_citation);
		$this->assign_by_ref('citation', $citation_validation);
	}
	
	public function before_citation_ajoute_commentaire() {
		$u = $this->get_user_session();
		self::cls($_GET['msg']);
		if (!empty($_GET['msg'])) {
			$citation = $u->get_citation_authok($_GET['id']);	
			$citation->ajoute_commentaire('info', $u->id_utilisateur, $_GET['msg']);
		}
		$this->redirect("?t=citation_liste_commentaires&id={$_GET['id']}");
	}
	
	public function before_v2_saisie() {
		$u = $this->get_user_session();
		$this->assign('key', IGN_KEY_POSTE);
		$this->assign('ouvre_repertoire', isset($_GET['apres_gpx']));
		$this->assign('x', $u->session_var_get(BOBS_POSTE_VS_X));
		$this->assign('y', $u->session_var_get(BOBS_POSTE_VS_Y));
		$this->assign('z', $u->session_var_get(BOBS_POSTE_VS_Z));
		$this->assign('xorg', CLICNAT_X_ORG);
		$this->assign('yorg', CLICNAT_Y_ORG);
		$this->assign('zorg', CLICNAT_Z_ORG);


		$_SESSION[SESS]['masque'] = 'v2_saisie';
	}
	
	public function before_v2_saisie_charge_gpx() {
		require_once(OBS_DIR.'gpx.php');
		$gpx = new bobs_gpx($_FILES['gpx']['tmp_name']);
		unlink($_FILES['gpx']['tmp_name']);		
		$_SESSION['gpx_wpts'] = serialize($gpx->get_wpts());
		$this->redirect('?t=v2_saisie&apres_gpx=1');	
	}
	
	public function before_repertoire_ajoute_point() {
		$u = $this->get_user_session();
		if ($u->repertoire_ajoute_point($_GET['nom'], $_GET['x'], $_GET['y'])) {
			echo "OK";
		}
		exit();
	}

	public function before_repertoire_ajoute_polygone() {	
		self::cls($_GET['geojson']);
		$wkt = bobs_espace_polygon::wkt_depuis_geojson($_GET['geojson']);
		$u = $this->get_user_session();
		if ($u->repertoire_ajoute_polygone($_GET['nom'], $wkt)) {
			echo "OK";
		}
		exit();
	}

	public function before_repertoire_ajoute_ligne() {	
		self::cls($_GET['geojson']);
		$wkt = bobs_espace_ligne::wkt_depuis_geojson($_GET['geojson']);
		$u = $this->get_user_session();
		if ($u->repertoire_ajoute_ligne($_GET['nom'], $wkt)) {
			echo "OK";
		}
		exit();
	}

	public function before_repertoire_supprime() {
		$u = $this->get_user_session();
		if ($u->repertoire_supprime($_GET['espace_table'], (int)$_GET['id_espace']))
			echo "OK";
		exit();
	}

	public function before_repertoire_liste() {
		$tri = bobs_utilisateur_repertoire::tri_par_nom;
		
		if (isset($_GET['par_date']))
			$tri = bobs_utilisateur_repertoire::tri_par_date;
			
		$u = $this->get_user_session();
		$repertoire = $u->repertoire_liste($tri);
		$this->assign_by_ref('repertoire', $repertoire);	
		if (isset($_SESSION['gpx_wpts'])) {		
			require_once(OBS_DIR.'gpx.php');	
			$gpx = unserialize($_SESSION['gpx_wpts']);			
			$this->assign_by_ref('gpx_wpts', $gpx);
		}
	}
	
	protected function before_img() {
		$w = (int)$_GET['w'];
		$h = (int)$_GET['h'];
		require_once(OBS_DIR.'/docs.php');
		$im = new bobs_document_image($_GET['id']);
		if (empty($w) && empty($h)) {
			$im->get_image();
		} else {
			$im->get_image_redim($w,$h);
		}
		exit();
	}
	
	public function before_citation_attache_doc() {
		require_once(OBS_DIR.'/docs.php');
		$u = $this->get_user_session();
		$citation =  $u->get_citation_authok($_POST['id']);
		$doc_id = bobs_document::sauve($_FILES['f']);
		$image = new bobs_document_image($doc_id);
		$image->ajoute_auteur($u->nom.' '.$u->prenom, $u->id_utilisateur);
		$citation->document_associer($doc_id);
		header('Location: '.$_POST['url_retour']);
		exit();
	}

	public function before_citation_attache_doc_inbox() {
		require_once(OBS_DIR.'/docs.php');
		$u = $this->get_user_session();
		$citation =  $u->get_citation_authok($_POST['id']);
		$citation->document_associer($_POST['doc_id']);
		$u->inbox_doc_suppr($_POST['doc_id']);
		header('Location: '.$_POST['url_retour']);
		exit();
	}

	public function before_espece_attache_doc() {
		require_once(OBS_DIR.'/docs.php');
		$u = $this->get_user_session();
		$espece = get_espece($this->db, $_POST['id']);
		$doc_id = bobs_document::sauve($_FILES['f']);
		$image = new bobs_document_image($doc_id);
		$image->ajoute_auteur($u->nom.' '.$u->prenom, $u->id_utilisateur);
		$image->mettre_en_attente();
		$espece->document_associer($doc_id);
		header('Location: '.$_POST['url_retour']);
		exit();
	}

	public function before_observation() {
		$observation = false;
		$peut_voir = false;
		$peut_modifier = false;

		if (isset($_GET['id_observation']))
			$observation = get_observation($this->db, (int)$_GET['id_observation']);
		elseif (isset($_GET['id'])) 
			$observation = get_observation($this->db, (int)$_GET['id']);

		if (!$observation) {
			$this->assign('obs', false);
			return;
		}

		$u = $this->get_user_session();

		$peut_modifier = $observation->autorise_modification($u);

		if ($u->acces_qg_ok()) {
			$peut_voir = true;
		}

		if ($u->get_observation_authok($observation)) {
			$peut_voir = true;
		}

		if ($peut_voir) {
			if (isset($_POST['commentaire'])) {
				bobs_element::cls($_POST['commentaire'], bobs_element::except_si_vide);
				$observation->ajoute_commentaire('info', $u->id_utilisateur, $_POST['commentaire']);
			}
			$this->assign_by_ref('obs', $observation);
			$this->assign('peut_modifier', $peut_modifier);
		} else {
			$this->assign('obs',false);
		}

		if (isset($_POST['date'])) {
			if ($peut_modifier) {
				$observation->modification($u->id_utilisateur, 'date_observation', $_POST['date']);
			} else {
				throw new Exception("Vous n'êtes pas autorisé a modifier cette observation");
			}
		}
	}

	public function before_citation_beta_validation() {
		$u = $this->get_user_session();
		$citation = $u->get_citation_authok($_GET['id']);
		if ($citation) {
			$this->assign('tests', $citation->validation_tests());
		} else {
			echo "Pas autorisé a voir cette citation";
			exit();
		}
	}

	public function before_citation() {
		$this->assign('id_citation', self::cli($_GET['id']));
		$peut_voir = false;
		$utilisateur_citation_authok = false;
		$this->assign('ages', bobs_citation::get_age_list());
		$this->assign('genres', bobs_citation::get_gender_list());

		// J'ai le droit de la voir elle dans les mad		
		if ($this->authok()) {			
			$u = $this->get_user_session();
			try {
				$citation = $u->get_citation_authok($_GET['id']);				
				if ($citation) {
					$peut_voir = true;
					$utilisateur_citation_authok = true;
				}
			} catch (Exception $e)  {
				
			}
		}
		
		// Peut être est-elle rendue public ?
		if (!$peut_voir) {
			$citation = get_citation($this->db, $_GET['id']);
			if ($citation->acces_public()) {
				$peut_voir = true;
			}
		}
		// 'info' / 'attr'
		if ($peut_voir && $this->authok()) {
			$redirect = false;
			if (array_key_exists('valider', $_GET)) {
				if ($citation->autorise_validation($u->id_utilisateur)) {
					$citation->validation($u->id_utilisateur);
					$redirect = true;
				}
			}
			if (array_key_exists('invalider', $_GET)) {
				if ($citation->autorise_validation($u->id_utilisateur)) {
					$citation->invalider($u->id_utilisateur);
					$redirect = true;
				}
			}
			if (array_key_exists('revalider', $_GET)) {
				if ($citation->autorise_validation($u->id_utilisateur)) {
					$citation->revalider($u->id_utilisateur);
					$redirect = true;
				}
			}
			if (array_key_exists('action', $_POST))
			switch ($_POST['action']) {
				case 'modifier':
					if ($citation->autorise_modification($u->id_utilisateur)) {
						switch ($_POST['champ']) {
							case 'id_espece':
								$citation->modification($u->id_utilisateur, 'id_espece', self::cli($_POST['id_espece']));
								break;
							case 'indice_qualite':
								$citation->modification($u->id_utilisateur, 'indice_qualite', self::cli($_POST['indice_qualite']));
								break;
							case 'nb':
								$citation->modification($u->id_utilisateur, 'nb', self::cli($_POST['nb']));
								break;
							case 'age':
								$citation->modification($u->id_utilisateur, 'age', self::cls($_POST['age']));
								break;
							case 'sexe':
								$citation->modification($u->id_utilisateur, 'sexe', self::cls($_POST['sexe']));
								break;
							case 'doc':
								$citation->document_detacher($_POST['doc_id']);
								$citation->ajoute_commentaire('attr', $u->id_utilisateur, "suppr doc {$_POST['doc_id']}");
								break;
							default:
								throw new Exception('quel champ modifier');
						}
						$redirect = true;
					} else {
						throw new Exception('pas autorisé a modifier cette citation');
					}
					break;
				case 'enregistre_commentaire':
					$u = $this->get_user_session();
					self::cls($_POST['c']);
					if (!empty($_POST['c'])) {
						$_POST['c'] = htmlentities($_POST['c'], ENT_QUOTES, 'UTF-8');
						$citation->ajoute_commentaire('info', $u->id_utilisateur, $_POST['c']);
						$redirect = true;
					}
					break;
				case 'ouvre_a_tous':
				case 'fermer_a_tous':
					$u = $this->get_user_session();
					$obs = $citation->get_observation();
					$peut_le_faire = false;
					
					// Si je suis l'auteur je peux l'ouvrir
					if ($u->id_utilisateur == $obs->id_utilisateur)
						$peut_le_faire = true;
					
					// Si je l'ai vu je le peux aussi
					if (!$peut_le_faire) {
						foreach ($obs->get_observateurs() as $o) {
							if ($o['id_utilisateur'] == $u->id_utilisateur) {
								$peut_le_faire = true;
								break;
							}
						}
					}
					
					if ($peut_le_faire) {
						$redirect = true;
						if ($_POST['action'] == 'ouvre_a_tous')
							$citation->rendre_public();
						else
							$citation->enlever_acces_public();
					}
					break;
			}
			if ($redirect) {
				$this->redirect('?t=citation&id='.$citation->id_citation);
				exit();
			}
		}
		
		$this->assign_by_ref('peut_voir', $peut_voir);
		$this->assign_by_ref('utilisateur_citation_authok', $utilisateur_citation_authok);
		
		if ($peut_voir) {
			$this->assign_by_ref('citation', $citation);
			$ev = clicnat_enquete_version::getInstanceFromXML($this->db, $citation->enquete_resultat);
			if ($ev) {
				$this->assign_by_ref('resultat_enquete', $ev->citation_reponses($citation));
			}
		}
	}
	
	public function authok() {
		return $_SESSION[SESS]['auth_ok'] == true;
	}

	private function get_user_session($reset=false) {
		if ($this->authok()) {
			if (!empty($_SESSION[SESS]['utilisateur'])) {
				$u = unserialize($_SESSION[SESS]['utilisateur']);
				$u->set_db($this->db);
				return $u;
			}
			if (!empty($_SESSION[SESS]['id_utilisateur']) || $reset)				
				return new bobs_utilisateur($this->db, $_SESSION[SESS]['id_utilisateur']);
			else
				throw new ExceptionErrAuth();
		}
		return false;
	}

	/* Section consacrée aux mangeoires */
	private function mangeoire() {
		require_once(OBS_DIR.'mangeoire.php');
		$u = $this->get_user_session();
		$u_mangeoire = new clicnat_mangeoire_observateur($this->db, $u->id_utilisateur);
		$this->assign_by_ref('observateur', $u_mangeoire);
		return $u_mangeoire;
	}

	protected function before_mangeoire_accueil() {
		$this->mangeoire();
	}

	protected function before_mangeoire_enregistrer() {
		$this->mangeoire();
		$this->assign('usemap', true);
	}

	protected function before_mangeoire_enregistre_point() {
		$um = $this->mangeoire();
		$data = array(
			'id_utilisateur' => $um->id_utilisateur,
			'reference' => 'mangeoire',
			'nom' => $_GET['nom'],
			'x' => $_GET['x'],
			'y' => $_GET['y']
		);
		$m = clicnat_mangeoire::insert($this->db, $data);
		$this->redirect('?t=mangeoire_accueil');
	}

	protected function before_mangeoire_set_effectif() {
		self::cli($_GET['nb']);
		self::cli($_GET['id_espece']);
		self::cli($_GET['id_observation']);
		$um = $this->mangeoire();
		$obs = new bobs_observation($this->db, $_GET['id_observation']);
		if ($obs->id_utilisateur != $um->id_utilisateur) {
			throw new Exception('pas le bon utilisateur');
		}
		if (!$obs->brouillard) {
			throw new Exception('déjà validée');
		}
		$citations = $obs->get_citations_ids();
		$fait = false;
		if (count($citations) > 0)
		foreach ($citations as $id) {
			$citation = $obs->get_citation($id);
			if ($citation->id_espece == $_GET['id_espece']) {
				if ($_GET['nb'] > 0) {
					$citation->set_effectif($_GET['nb']);
					$fait = true;
				} else {
					$citation->delete();
					$fait = true;
				}
			}
		}
		// Ajout de l'espèce à l'observation
		if (!$fait) {
			$id = $obs->add_citation($_GET['id_espece']);
			$citation = $obs->get_citation($id);
			$tag = bobs_tags::by_ref($this->db, '9100'); // mange 	
			$citation->ajoute_tag($tag->id_tag);
			$tag = bobs_tags::by_ref($this->db, '9101'); // mange à la mangeoire
			$citation->ajoute_tag($tag->id_tag);
			$tag = bobs_tags::by_ref($this->db, '4000'); // posé
			$citation->ajoute_tag($tag->id_tag);
			$citation->set_effectif($_GET['nb']);
			$citation->set_indice_qualite(bobs_indice_qualite::indice_qualite_max);
			$um->add_citation_authok($citation->id_citation);
		}
			
		echo $_GET['nb'];
		exit();
	}

	protected function before_mangeoire_creation_obs() {
		$u = $this->mangeoire();
		$mangeoire = new clicnat_mangeoire($this->db, $_GET['id_espace']);
		if ($mangeoire->a_observateur($u->id_utilisateur)) {
			$data = array(
				'id_utilisateur' => $u->id_utilisateur,
				'date_observation' => bobs_element::date_fr2sql($_GET['date']),
				'id_espace' => $mangeoire->id_espace,
				'table_espace' => $mangeoire->get_table()
			);
			$id_observation = bobs_observation::insert($this->db, $data);
			$observation = new bobs_observation($this->db , $id_observation);
			$observation->add_observateur($u->id_utilisateur);
			$this->redirect('?t=mangeoire_inventaire&id='.$id_observation);
		}
		throw new Exception('Pas observateur sur cette mangeoire');
	}

	protected function before_mangeoire_inventaire() {
		$u = $this->mangeoire();
		$obs = new bobs_observation($this->db, $_GET['id']);
		if ($obs->id_utilisateur != $u->id_utilisateur) {
			throw new Exception('Pas créateur de cette observation');
		}
		$mangeoire = new clicnat_mangeoire($this->db, $obs->id_espace);
		$this->assign('mangeoire', $mangeoire);
		$this->assign('obs', $obs);
	}

	protected function before_mangeoire_inventaire_fin() {
		$u = $this->mangeoire();
		$obs = new bobs_observation($this->db, $_GET['id']);
		if ($obs->id_utilisateur != $u->id_utilisateur) {
			throw new Exception('Pas créateur de cette observation');
		}
		$obs->send();
	}

	protected function before_mangeoire_liste_observateur() {
		$u = $this->mangeoire();
		$mangeoire = new clicnat_mangeoire($this->db, $_GET['id']);
		if (!$mangeoire->a_observateur($u->id_utilisateur)) {
			throw new Exception('pas membre de cette mangeoire');
		}
		$this->assign('proprietaire', $u->id_utilisateur == $mangeoire->id_utilisateur);
		$this->assign_by_ref('mangeoire', $mangeoire);
		if ($u->id_utilisateur == $mangeoire->id_utilisateur) {
			if (array_key_exists('ajouter', $_GET)) {
				bobs_tests::cli($_GET['ajouter'], bobs_tests::except_si_inf_1);
				$mangeoire->ajoute_observateur($_GET['ajouter']);
				$this->redirect('?t=mangeoire_liste_observateur&id='.$mangeoire->id_espace);
			} else if (array_key_exists('retirer', $_GET)) {
				bobs_tests::cli($_GET['retirer'], bobs_tests::except_si_inf_1);
				$mangeoire->supprime_observateur($_GET['retirer']);
				$this->redirect('?t=mangeoire_liste_observateur&id='.$mangeoire->id_espace);
			}
		}
	}

	protected function before_mangeoire_rapport() {
		$u = $this->mangeoire();
		$mangeoire = new clicnat_mangeoire($this->db, $_GET['id']);

		if (!$mangeoire->a_observateur($u->id_utilisateur)) 
			throw new Exception('pas membre de cette mangeoire');

		$this->assign('mangeoire', $mangeoire);
	}

	protected function before_lepido_rpg() {
		require_once(OBS_DIR.'calendriers.php');
		$dates = bobs_calendrier::get_dates_tag($this->db, 'lepido rpg');
		$this->assign_by_ref('dates', $dates);
	}

	protected function before_lepido_rpg_geocode() {
		$cultures = array(
			"PAS D'INFORMATION",
			"BLE TENDRE",
			"MAIS GRAIN ET ENSILAGE",
			"ORGE",
			"AUTRES CEREALES",
			"COLZA",
			"TOURNESOL",
			"AUTRES OLEAGINEUX",
			"PROTEAGINEUX",
			"PLANTES A FIBRES",
			"SEMENCES",
			"GEL (SURFACES GELEES SANS PRODUCTION)",
			"GEL INDUSTRIEL",
			"AUTRES GELS",
			"RIZ",
			"LEGUMINEUSES A GRAINS",
			"FOURRAGE",
			"ESTIVES LANDES",
			"PRAIRIES PERMANENTES",
			"PRAIRIES TEMPORAIRES",
			"VERGERS",
			"VIGNES",
			"FRUITS A COQUE",
			"OLIVIERS",
			"AUTRES CULTURES INDUSTRIELLES",
			"LEGUMES-FLEURS",
			"CANNE A SUCRE",
			"ARBORICULTURE",
			"DIVERS"
		);
		$espaces = bobs_espace_polygon::get_espaces_in_point($this->db, $_GET['x'], $_GET['y']);
		$espace = null;
		foreach ($espaces as $espace) {
			if (!preg_match('/^RPG-2010-.*/', $espace->nom)) {
				$espace = null;
				continue;
			} else {
				break;
			}
		}
		$this->assign_by_ref('espace', $espace);
		if (!is_null($espace)) {
			$this->assign_by_ref('culture', $cultures[$espace->reference]);
			require_once(OBS_DIR.'calendriers.php');
			$dates = bobs_calendrier::get_dates_espace($this->db, $espace->get_table(), $espace->id_espace);
			$this->assign_by_ref('dates', $dates);
		}
	}

	public function before_lepido_rpg_dates() {
		$dates = bobs_calendrier::get_dates_tag($this->db, 'lepido rpg');
		$r = $dates->get_datatable($_GET);
		$ret = array();
		$n = 0;
		foreach ($r['aaData'] as $d) {
			$n = ($n+1)%100;
			$im = sprintf("<img class=\"icone_carte\" src=\"icones/numeric/black%02d.png\" x=\"%F\" y=\"%F\"/>",
				$n,
				$d[clicnat_iterateur_calendrier::dtable_c_x],
				$d[clicnat_iterateur_calendrier::dtable_c_y]
			);
			$ret[] = array(
				"<a href='javascript:lepido_rpg_edit_date({$d[clicnat_iterateur_calendrier::dtable_c_id_date]});'>{$d[clicnat_iterateur_calendrier::dtable_c_date]}</a> <small><a href='javascript:lepido_rpg_annul_date({$d[clicnat_iterateur_calendrier::dtable_c_id_date]});'>annuler</a></small>",
				$d[clicnat_iterateur_calendrier::dtable_c_participants],
				$d[clicnat_iterateur_calendrier::dtable_c_espace_nom]." $im"
			);
			
		}
		$r['aaData'] = $ret;
		echo json_encode($r);
		exit();
		
	}

	public function before_espace() {
		require_once(OBS_DIR.'/extractions.php');
		require_once(OBS_DIR.'/extractions-conditions.php');
		if (!isset($_GET['table']))
			throw new InvalidArgumentException('manque paramètre $table');
		if (!isset($_GET['id_espace']))
			throw new InvalidArgumentException('manque paramètre $id_espace');

		$espace = false;
		$extraction = false;
		switch ($_GET['table']) {
			case 'espace_point':
				$espace = get_espace_point($this->db, (int)$_GET['id_espace']);
				break;
			case 'espace_polygon':
				$espace = get_espace_polygon($this->db, (int)$_GET['id_espace']);
				$extraction = new bobs_extractions_poste($this->db, $this->get_user_session()->id_utilisateur);
				$extraction->ajouter_condition(new bobs_ext_c_poly($_GET['table'], 'espace_point', (int)$_GET['id_espace']));
				break;
		}
		
		$this->assign('espace', $espace);
		$this->assign('extraction', $extraction);
	}

	public function before_flux() {
		if (!isset($_SESSION[SESS]['flux'])) {
			$_SESSION[SESS]['flux'] = new bobs_extractions($this->db);
		}
		$extraction = $_SESSION[SESS]['flux'];
		$extraction->set_db($this->db);
		if (isset($_GET['action'])) {
			switch ($_GET['action']) {
				case 'ajouter_commune':
					$extraction->ajouter_condition(new bobs_ext_c_commune((int)$_GET['id_commune']));
					break;
				case 'ajouter_espece':
					$extraction->ajouter_condition(new bobs_ext_c_taxon_branche((int)$_GET['id_espece']));
					break;
				case 'retirer':
					$extraction->retirer_condition((int)$_GET['n']);
					break;
			}
			$_SESSION[SESS]['flux'] = $extraction;
			header("Location: ?t=flux");
		}
		$this->assign_by_ref('extraction', $extraction);
	}

	public function before_flux_contenu() {
		try { 
			$u = $this->get_user_session();
			$limite_reseau = false;
			if (defined('INSTALL')) {
				if (INSTALL == 'picnat') {
					$limite_reseau = true;
					$reseaux_ok = ['av'];
				}
			}

			$reseaux = [];

			foreach ($u->get_reseaux() as $reseau) {
				//if (get_class($reseau) == 'clicnat2_reseau')
				//	continue;
				if ($limite_reseau) {
					if (in_array($reseau->id, $reseaux_ok)) {
						$reseaux[] = $reseau;
					}
				} else {
					$reseaux[] = $reseau;
				}
			}
			if (count($reseaux) == 0) {
				throw new Exception('inscrit dans aucun réseau');
			}
			//$extraction = new bobs_extractions($this->db);
			$extraction = clone $_SESSION[SESS]['flux'];
			$extraction->set_db($this->db);
			$extraction->ajouter_condition(new bobs_ext_c_brouillard(false));
			$extraction->ajouter_condition(new bobs_ext_c_precision_date_max(10));
			$extraction->ajouter_condition(new bobs_ext_c_sans_tag_invalide());
			foreach ($reseaux as $reseau) 
				$extraction->ajouter_condition(new bobs_ext_c_reseau($reseau));
		
			switch ($_GET['filtre_type']) {
				default:
					break;
			}
		
			// on renvoi ici la timeline avant d'ajouter les limites de dates
			if (isset($_GET['timeline'])) {
				header('Content-Type: application/json');
				echo json_encode($extraction->mois_et_annees());
				exit();
			} 

			$extraction->ajouter_condition(new bobs_ext_c_mois((int)$_GET['flux_p_mois']));
			$extraction->ajouter_condition(new bobs_ext_c_annee((int)$_GET['flux_p_annee']));
			$citations = $extraction->get_citations();
			$citations->inverse();
			$this->assign_by_ref('citations', $citations);
		} catch (Exception $e) {
			header("Content-Type: application/json");
			header("HTTP/1.0 503 Service Unavailable");
			echo json_encode(array('err' => $e->getMessage()));
			exit();
		}
	}

	public function display() {
		global $start_time;
		$this->session();
		try {
			$this->default_assign();
			$tpl = $this->template();
			if ($tpl != 'accueil' and $tpl != 'reglement_seul'  and $tpl != 'atlas_oiseaux_nicheurs_xml' and $tpl != 'citation' and $tpl != 'inscription' and $tpl != 'atlas_oiseaux_nicheurs_xml_winter') {
				if (!$this->authok())
					throw new ExceptionErrAuth();
				$u = $this->get_user_session();
				$this->assign_by_ref('u', $u);
				if ($tpl != 'reglement' && !$u->agreed_the_rules())
					throw new ExceptionReglement();
			}
			setlocale(LC_ALL, LOCALE);
			$before_func = 'before_'.$this->template();

			if (method_exists($this, $before_func))
				$this->$before_func();

			if ($tpl != 'accueil' and $tpl != 'reglement_seul') {
				$u = $this->get_user_session();
				$this->assign_by_ref('u', $u);
			}
			$this->assign_by_ref('bobs_msgs', $this->bobs_msgs);
		} catch(ExceptionErrAuth $e) {
			$tpl = 'accueil';
			$this->assign('messageinfo', 'Vous avez été déconnecté ou votre session a expiré');
		} catch(ExceptionReglement $e) {
			header('Location: ?t=reglement');
			exit();
		} catch(Exception $e) {
			$tpl = 'exception';
			$this->assign('ex', $e);
			try {
				$u = $this->get_user_session();
			} catch (Exception $e) { }
			$headers = "From: bobs@picardie-nature.org\r\nContent-Type: text/plain; charset=UTF-8";
			$f = basename($e->getFile()).' ligne '.$e->getLine();
			$msg = "Message : {$e->getMessage()}\nFichier : $f\n";
			$msg .= "Query String : {$_SERVER['QUERY_STRING']}\n";
			$msg .= "Origine : {$_SERVER['HTTP_REFERER']}\n";
			$msg .= "Trace :\n";
			foreach ($e->getTrace() as $ele)
			    $msg .= sprintf("\t%-40s %s%s%s()\n", basename($ele['file'])." +{$ele['line']}",  $ele['class'], $ele['type'], $ele['function']);
			mail('nicolas.damiens@picardie-nature.org', "BOBS ERREUR - {$u->nom} {$u->prenom} ({$u->id_utilisateur})", $msg, $headers);
			$this->assign('msg', htmlentities($msg, ENT_COMPAT | ENT_HTML401, 'UTF-8'));
		}
		$this->assign('tps_exec_avant_display', sprintf('%0.4f', microtime(true) - $start_time));
		parent::display($tpl.'.tpl');
		/*$u = $this->get_user_session();
		if ($u->acces_qg_ok()) {
			echo "<pre style='text-align:left; font-size:10px;'>";
			bobs_qm()->vdump();
		}*/
	}
}

require_once(DB_INC_PHP);
get_db($db);
$poste = new Poste($db);
$poste->display();
?>
