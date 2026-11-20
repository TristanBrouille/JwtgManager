package com.seckmet.jwtgmanager.progress.domain;

import com.seckmet.jwtgmanager.shared.domain.Currency;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class CompletionAggregatorTest {

    private static ProgressLine line(Currency c, double progress, int l40, int target, long invested, long remaining) {
        return new ProgressLine(1, "x", "C", c, true, progress >= 1, l40, target, progress, invested, remaining);
    }

    @Test
    void summarize_averagesSpeciesProgress_likeTheExcel() {
        CompletionSummary s = CompletionAggregator.summarize(List.of(
                line(Currency.DNA, 1.0, 3, 3, 2400, 0),
                line(Currency.AMBER, 0.0, 0, 3, 0, 600000),
                line(Currency.SUPER_DNA, 0.5, 0, 3, 6000, 6000)));
        assertThat(s.completion()).isEqualTo(0.5);
        assertThat(s.done()).isEqualTo(1);
        assertThat(s.lvl40()).isEqualTo(3);
        assertThat(s.lvl40Target()).isEqualTo(9);
        assertThat(s.dnaInvested()).isEqualTo(2400);
        assertThat(s.superDnaRemaining()).isEqualTo(6000);
        assertThat(s.amberRemaining()).isEqualTo(600000);
    }

    @Test
    void summarize_emptyIsZero() {
        assertThat(CompletionAggregator.summarize(List.of()).completion()).isZero();
    }

    @Test
    void weeksToFinish_roundsUp_andIsEmptyWithoutIncome() {
        assertThat(CompletionAggregator.weeksToFinish(100, 30)).contains(4L);
        assertThat(CompletionAggregator.weeksToFinish(0, 0)).contains(0L);
        assertThat(CompletionAggregator.weeksToFinish(100, 0)).isEmpty();
    }
}
