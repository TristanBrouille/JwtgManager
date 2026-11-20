package com.seckmet.jwtgmanager.shared.domain;

/**
 * Monnaie de paiement d'un palier.
 * <ul>
 *   <li>ADN : espèce débloquée (espèce de base ou hybride) ;</li>
 *   <li>super ADN : super hybride débloqué ;</li>
 *   <li>ambre : espèce non débloquée (si son coût ambre est inconnu, on reste en ADN / super ADN).</li>
 * </ul>
 */
public enum Currency {
    DNA("ADN"), SUPER_DNA("super ADN"), AMBER("ambre");

    private final String label;

    Currency(String label) {
        this.label = label;
    }

    public String label() {
        return label;
    }

    public static Currency of(boolean unlocked, boolean superHybrid) {
        if (!unlocked) {
            return AMBER;
        }
        return superHybrid ? SUPER_DNA : DNA;
    }
}
