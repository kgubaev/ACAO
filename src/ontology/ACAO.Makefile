
export ROBOT_PLUGINS_DIRECTORY = /tools/robot-plugins


# ----------------------------
# Custom lightweight IAO import
# ----------------------------
imports/iao_import.owl: mirror/iao.owl imports/iao_terms.txt tmp/seed.txt | all_robot_plugins
	$(ROBOT) extract \
	  --input $< \
	  --method BOT \
	  --term-file imports/iao_terms.txt \
	  --output tmp/iao_extracted.owl
	$(ROBOT) remove \
	  --input tmp/iao_extracted.owl \
	  --select individuals \
	  --select object-properties \
	  --select data-properties \
	  --output $@


imports/om-2_import.owl: mirror/om-2.owl imports/om-2_terms.txt | all_robot_plugins
	@mkdir -p tmp
	@echo 'PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>' >  tmp/om2_construct.sparql
	@echo 'PREFIX owl:  <http://www.w3.org/2002/07/owl#>'            >> tmp/om2_construct.sparql
	@echo 'PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>'     >> tmp/om2_construct.sparql
	@echo ''                                                         >> tmp/om2_construct.sparql
	@echo 'CONSTRUCT {'                                               >> tmp/om2_construct.sparql
	@echo '  ?u rdf:type ?t .'                                        >> tmp/om2_construct.sparql
	@echo '  ?u rdfs:label ?lab .'                                    >> tmp/om2_construct.sparql
	@echo '} WHERE {'                                                 >> tmp/om2_construct.sparql
	@echo '  VALUES ?u {'                                             >> tmp/om2_construct.sparql

	@awk 'BEGIN{} \
	      { gsub(/\r/,""); } \
	      /^[[:space:]]*#/ { next } \
	      /^[[:space:]]*$$/ { next } \
	      { gsub(/^[[:space:]]+/,""); gsub(/[[:space:]]+$$/,""); } \
	      { sub(/^</,""); sub(/>$$/,""); } \
	      { print "    <" $$0 ">" }' imports/om-2_terms.txt >> tmp/om2_construct.sparql

	@echo '  }'                                                       >> tmp/om2_construct.sparql
	@echo '  OPTIONAL { ?u rdf:type ?t . }'                            >> tmp/om2_construct.sparql
	@echo '  OPTIONAL { ?u rdfs:label ?lab . }'                        >> tmp/om2_construct.sparql
	@echo '}'                                                         >> tmp/om2_construct.sparql

	$(ROBOT) query --input mirror/om-2.owl --query tmp/om2_construct.sparql $@

	$(ROBOT) annotate \
	  --input $@ \
	  --ontology-iri http://www.ontology-of-units-of-measure.org/resource/om-2 \
	  --annotation http://purl.org/dc/terms/source https://raw.githubusercontent.com/HajoRijgersberg/OM/refs/heads/master/om-2.0.rdf \
	  --output $@.tmp.owl && mv $@.tmp.owl $@

	robot --catalog catalog-v001.xml --prefixes prefixes.json \
	convert --input imports/om-2_import.owl --output imports/om-2_import.owl


