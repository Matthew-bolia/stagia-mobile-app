abstract final class EndpointsApi {
  static const connexion =
      '/stagia/api/v1/auth/login.php'; // endpoints pour la connexion
  static const profilEtudiant = '/stagia/api/v1/me.php';
  static const documentsEtudiant = '/stagia/api/v1/student/documents.php';
  static const stagesEtudiant = '/stagia/api/v1/student/stages.php';
  static const reservationsEtudiant = '/stagia/api/v1/student/reservations.php';
  static const admissionEtudiant = '/stagia/api/v1/student/admission.php';
  static const optionsStageEtudiant =
      '/stagia/api/v1/student/stage-options.php';
  static const candidaturesEtudiant = '/stagia/api/v1/student/applications.php';
  static const tableauDeBordEtudiant = '/stagia/api/v1/student/dashboard.php';
  static const presencesEtudiant = '/stagia/api/v1/student/attendance.php';
  static const journalEtudiant = '/stagia/api/v1/student/logbook.php';
  static const evaluationsEtudiant = '/stagia/api/v1/student/evaluations.php';
  static const paiementsEtudiant = '/stagia/api/v1/student/payments.php';
  static const rafraichirToken = '/auth/token/refresh';
  static const deconnexion = '/auth/logout';
  static const motDePasseOublie = '/auth/password/forgot';
  static const reinitialiserMotDePasse = '/auth/password/reset';
  static const rechercherInscription = '/students/claim/lookup';
  static const verifierInscription = '/students/claim/verify';
  static const creerCompteEtudiant = '/auth/student/register';
  static const regenererIdentifiantStagia = '/stagia/api/v1/me.php';
  static const ajouterEmail = '/me/login-identifiers/email';
  static const ajouterTelephone = '/me/login-identifiers/phone';
  static String verifierIdentifiant(String id) =>
      '/me/login-identifiers/$id/verify';

  // Référentiel public utilisé pendant l'inscription
  static const universites = '/public/universities';
  static String anneesAcademiques(String universiteId) =>
      '/public/universities/$universiteId/academic-years';
  static String facultes(String universiteId) =>
      '/public/universities/$universiteId/faculties';
  static String promotions(String universiteId) =>
      '/public/universities/$universiteId/promotions';

  // Stages, candidatures et réservations
  static const campagnes = '/campaigns';
  static String opportunites(String campagneId) =>
      '/campaigns/$campagneId/opportunities';
  static const candidatures = '/applications';
  static String reserverPlace(String candidatureId) =>
      '/applications/$candidatureId/reservations';
  static String confirmerReservation(String reservationId) =>
      '/reservations/$reservationId/confirm';
  static String annulerReservation(String reservationId) =>
      '/reservations/$reservationId/cancel';
  static String exigencesFinancieres(String campagneId) =>
      '/campaigns/$campagneId/financial-requirements';
  static const paiements = '/payments';
  static String verifierPaiement(String paiementId) =>
      '/payments/$paiementId/verify';

  // Stage actif, présences et activités
  static String feuillePresence(String affectationId) =>
      '/assignments/$affectationId/attendance-sheet';
  static String justifierAbsence(String presenceId) =>
      '/attendance/$presenceId/justification';
  static String ajouterActivite(String stageId) =>
      '/internships/$stageId/activities';
  static const referentielEvaluation = '/evaluation-frameworks/current';

  // Médias et documents
  static const medias = '/media';
  static String media(String mediaId) => '/media/$mediaId';
  static String versionsMedia(String mediaId) => '/media/$mediaId/versions';
  static String lierMedia(String mediaId) => '/media/$mediaId/links';
  static String archiverMedia(String mediaId) => '/media/$mediaId/archive';
  static String urlTelechargement(String mediaId) =>
      '/media/$mediaId/download-url';

  // Accueil
  static const tableauDeBord = '/analytics/overview';
}
