package com.seckmet.jwtgmanager.catalog.application;

/** Liens vers les images et la page source d'une créature, à partir de sa clé source. */
public interface CreatureMedia {
    String imageUrl(String sourceKey);

    /** Portrait du palier {@code evolution} (1 = niveau 10 … 4 = niveau 40). */
    String portraitUrl(String sourceKey, int evolution);

    String sourcePageUrl(String sourceKey);
}
