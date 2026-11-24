package com.seckmet.jwtgmanager.catalog.infrastructure;

import com.seckmet.jwtgmanager.catalog.application.CreatureMedia;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/** Images et pages hébergées par paleo.gg, d'où viennent les fiches de jeu. */
@Component
class PaleoCreatureMedia implements CreatureMedia {

    private final String cdnUrl;
    private final String pageUrl;

    PaleoCreatureMedia(@Value("${jwtg.paleo.cdn-url}") String cdnUrl,
                       @Value("${jwtg.paleo.page-url}") String pageUrl) {
        this.cdnUrl = strip(cdnUrl);
        this.pageUrl = strip(pageUrl);
    }

    @Override
    public String imageUrl(String sourceKey) {
        return cdnUrl + "/creature/" + sourceKey + ".png";
    }

    @Override
    public String portraitUrl(String sourceKey, int evolution) {
        return cdnUrl + "/creature-portrait/" + sourceKey + "_evo" + evolution + ".png";
    }

    @Override
    public String sourcePageUrl(String sourceKey) {
        return pageUrl + "/" + sourceKey;
    }

    private static String strip(String url) {
        return url.endsWith("/") ? url.substring(0, url.length() - 1) : url;
    }
}
