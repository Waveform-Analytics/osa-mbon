ui_overview <- fluidPage(
  h1("Project overview"),
  p(
    "The passive acoustic data used for this exploratory project are derived 
    from the locations and projects indicated below. Selecting a location opens 
    information regarding the dataset origin and point of contact. Below the map 
    is a description of all acoustic indices calculated for this exploratory 
    analysis."
  ),
  layout_columns(
    card(
      leafletOutput("overviewMap")
    ),
    card(
      h3("BioSound Project"),
      p(
        "The BioSound Working Group initiated the exploratory study responsible 
        for this dashboard. The intent of this analysis is to identify trends in 
        several soundscape ecology metrics across different ocean environments. 
        To enable accessible exploration of the data products resulting from this 
        analysis, this dashboard provides a series of interactive figures for 
        assessing these acoustic-based biodiversity indices. The following 
        explorations are available from each of the sub-tabs accessed by the 
        “Data Explorer” tab above: "
      ),
      tags$ul(
        tags$li(tags$strong("Diurnal Trends"), ": acoustic-based indices are plotted by 
        hour to evaluate diurnal potential trends."),
        tags$li(tags$strong("Annotations"), ": biological and anthropogenic noise
        annotations provided by the May River and Key West datasets are
        highlighted on this tab."),
        tags$li(tags$strong("Water Classes"), ": correlations between water class type
        and acoustic-based indices are explored by dataset, along with water
        mass percentage and mean index values summed over 8-day intervals."),
        tags$li(tags$strong("All Datasets"), ": explore acoustic-based indices
                and their relationships per dataset.")
      ),
      p(
        "Click locations on the map to see site-specific information."
      ),
      p(
        "For a full description of the methods and analytical processes involved
        in this project, please visit",
        tags$a("BioSound Project Documentation Site",
               href="https://ocean-science-analytics.github.io/biosound-exploratory-project/overview.html",
               target="_blank")
      )
    )
  ),
  card(
    h3("Description of Indices"),
    p(
      "For a full description of indices, visit the ",
      tags$a("documentation site",
             href="https://ocean-science-analytics.github.io/biosound-exploratory-project/overview.html",
             target="_blank")
    ),
    p(tags$strong("ACI (Acoustic Complexity Index)"), ": Quantifies the complexity of sound by evaluating the variation in amplitude among frequency bands."),
    p(tags$strong("ACTspCount (Active Space Count)"), ": Count of spatial areas showing significant sound activity."),
    p(tags$strong("ACTspFract (Active Space Fraction)"), ": Fraction of the spatial domain showing active sound production."),
    p(tags$strong("ACTspMean (Active Space Mean)"), ": Average level of sound activity across spatial areas."),
    p(tags$strong("ACTtCount (Active Time Count)"), ": Number of times the sound level exceeds the predefined threshold (3 dB)."),
    p(tags$strong("ACTtFraction (Active Time Fraction)"), ": Proportion of the recording duration where the sound level exceeds a predefined threshold."),
    p(tags$strong("ACTtMean (Active Time Mean)"), ": Average sound level during active times."),
    p(tags$strong("ADI (Acoustic Diversity Index)"), ": Measures the variety of sound frequencies present, indicative of biodiversity."),
    p(tags$strong("AEI (Acoustic Evenness Index)"), ": Evaluates the evenness of the distribution of sound energy across frequencies."),
    p(tags$strong("AGI (Acoustic Gap Index)"), ": Index measuring the gaps or silent intervals within the acoustic signal, indicative of disturbance."),
    p(tags$strong("AnthroEnergy (Anthropogenic Energy)"), ": Measure of energy associated with human-made sounds."),
    p(tags$strong("BGNf (Background Noise Level Frequency)"), ": Background noise level in the frequency domain."),
    p(tags$strong("BGNt (Background Noise Level Time)"), ": Level of background noise in the time domain."),
    p(tags$strong("BI (Biotic Index)"), ": Index evaluating the presence of biological sounds."),
    p(tags$strong("BioEnergy (Biophonic Energy)"), ": Measure of energy associated with natural sounds."),
    p(tags$strong("EAS (Energy Acoustic Spectrum)"), ": Total acoustic energy measured across the spectrum."),
    p(tags$strong("ECU (Evenness of the Channel Utilization)"), ": Evenness with which different frequency channels are utilized."),
    p(tags$strong("ECV (Energy Coefficient of Variation)"), ": Coefficient of variation of the energy across different frequency bands."),
    p(tags$strong("ENRf (Energy Ratio Frequency)"), ": Ratio of energy within certain frequency bands compared to the total energy."),
    p(tags$strong("EPS (Energy Peak Spectrum)"), ": Measure of the peak energy in the spectrum."),
    p(tags$strong("EPS_KURT (Energy Peak Spectrum Kurtosis)"), ": Kurtosis of the energy peak spectrum, indicating the shape of the peak distribution."),
    p(tags$strong("EPS_SKEW (Energy Peak Spectrum Skewness)"), ": Skewness of the energy peak spectrum, indicating the asymmetry of the peak distribution."),
    p(tags$strong("EVNspCount (Event Space Count)"), ": Count of sound events in spatial areas."),
    p(tags$strong("EVNspFract (Event Space Fraction)"), ": Fraction of the spatial domain where sound events occur."),
    p(tags$strong("EVNspMean (Event Space Mean)"), ": Average level of sound events across spatial areas."),
    p(tags$strong("EVNtCount (Event Time Count)"), ": Number of distinct sound events detected."),
    p(tags$strong("EVNtFraction (Event Time Fraction)"), ": Fraction of time that 'events' (heightened sound activity) occur."),
    p(tags$strong("EVNtMean (Event Time Mean)"), ": Average sound level during event times."),
    p(tags$strong("H_gamma (Gamma Entropy)"), ": Entropy measure based on the gamma distribution, used for sound diversity."),
    p(tags$strong("H_GiniSimpson (Gini-Simpson Entropy)"), ": Entropy based on the Gini-Simpson index, reflecting diversity and probability."),
    p(tags$strong("H_Havrda (Havrda Entropy)"), ": Entropy measure based on Havrda-Charvat entropy, reflecting diversity."),
    p(tags$strong("H_pairedShannon (Paired Shannon Entropy)"), ": Shannon entropy calculated from paired data sets for comparing diversity."),
    p(tags$strong("H_Renyi (Renyi Entropy)"), ": Generalized entropy measure capturing diversity and richness of the soundscape."),
    p(tags$strong("Hf (High Frequency Coverage)"), ": Extent to which high frequencies are present in the soundscape."),
    p(tags$strong("HFC (High Frequency Coverage)"), ": Reiterates the presence and extent of high frequencies in the soundscape."),
    p(tags$strong("KURTf (Kurtosis Frequency)"), ": 'Tailedness' of the frequency distribution, indicating infrequent extreme frequency deviations."),
    p(tags$strong("KURTt (Kurtosis Time)"), ": 'Tailedness' of the amplitude distribution in the time domain, indicating infrequent extreme deviations."),
    p(tags$strong("LEQf (Long-term Equivalent Level Frequency)"), ": Equivalent constant sound level in the frequency domain that conveys the same sound energy."),
    p(tags$strong("LEQt (Long-term Equivalent Level Time)"), ": Constant sound level that delivers the same sound energy as the varying sound level over a specified period."),
    p(tags$strong("LFC (Low Frequency Coverage)"), ": Extent to which low frequencies are present in the soundscape."),
    p(tags$strong("MEANf (Mean Frequency)"), ": Average frequency of sounds, weighted by their amplitude."),
    p(tags$strong("MEANt (Mean Time)"), ": The average amplitude of the audio signal over time, reflecting the overall loudness."),
    p(tags$strong("MFC (Mid Frequency Coverage)"), ": Extent to which mid-range frequencies are present in the soundscape."),
    p(tags$strong("NBPEAKS (Number of Peaks)"), ": Total number of prominent peaks in the frequency spectrum."),
    p(tags$strong("NDSI (Normalized Difference Soundscape Index)"), ": Index of the balance between biological sounds and anthropogenic noise."),
    p(tags$strong("RAOQ (Rao's Quadratic Entropy)"), ": Entropy measure that considers both abundance and dissimilarity among categories."),
    p(tags$strong("rBA (relative Biophony-Anthrophony)"), ": Relative levels of biophony (natural sounds) and anthrophony (human-made sounds)."),
    p(tags$strong("ROIcover (Region of Interest Coverage)"), ": Extent to which regions of interest cover the acoustic space."),
    p(tags$strong("ROItotal (Region of Interest Total)"), ": Total measure or count of regions of interest identified within the soundscape."),
    p(tags$strong("ROU (Roughness)"), ": Measure of the texture or roughness of the sound profile."),
    p(tags$strong("SKEWf (Skewness Frequency)"), ": Asymmetry of the frequency distribution of the sound."),
    p(tags$strong("SKEWt (Skewness Time)"), ": Asymmetry of the amplitude distribution of the audio signal in the time domain."),
    p(tags$strong("SNRf (Signal-to-Noise Ratio Frequency)"), ": Ratio of signal level to noise level in the frequency domain."),
    p(tags$strong("SNRt (Signal-to-Noise Ratio Time)"), ": Ratio of the audio signal level to the level of background noise."),
    p(tags$strong("TFSD (Temporal Frequency Spectral Diversity)"), ": Diversity of frequencies over time, reflecting temporal variation."),
    p(tags$strong("VARf (Variance Frequency)"), ": Variance in the frequency of sounds, indicating dispersion around the mean frequency."),
    p(tags$strong("VARt (Variance Time)"), ": Variance of the time-domain audio signal amplitude, indicating amplitude fluctuations over time."),
    p(tags$strong("ZCR (Zero Crossing Rate)"), ": Measures the rate at which the signal changes from positive to negative or back, indicating the frequency content of the sound.")
    
    
    
  )
  
)