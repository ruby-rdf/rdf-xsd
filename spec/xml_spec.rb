require_relative 'spec_helper'
begin
  require 'nokogiri'
rescue LoadError
end
require 'rexml/document'

describe RDF::Literal do
  describe "XML" do
    %w(Nokogiri REXML).each do |impl|
      next unless Module.constants.map(&:to_s).include?(impl)
      context impl do
        before(:all) { @library = impl.downcase.to_sym}
        context "with a node" do
          subject {
            @obj = parse_node("<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>", impl)
            RDF::Literal::XML.new(@obj, :library => @library)
          }
          
          it "has equivalent object representation" do
            expect(subject.object).to eq @obj
          end

          it "provides a value" do
            expect(subject.value).to eq @obj.to_s
          end
          
          it "provides value for #to_s" do
            expect(subject.to_s).to eq @obj.to_s
          end
          
          it "== another (object)" do
            expect(subject).to eq subject.dup
          end
          
          it "== another (value)" do
            expect(subject).to eq RDF::Literal::XML.new(@obj.to_s, :library => @library)
          end
        end

        context "with a node (string)" do
          subject {
            @string = "<doc xmlns='foo:bar'><first>foo  bar baz</first><second>things</second></doc>"
            @obj = parse_node(@string, impl)
            RDF::Literal::XML.new(@string, :library => @library)
          }
          
          it "has equivalent object representation" do
            expect(subject.value).to eq @string
          end

          it "provides an object" do
            expect(subject.object.to_s).to eq (impl == "REXML" ? [@obj].to_s : @obj.to_s)
          end
          
          it "provides value for #to_s" do
            expect(subject.value).to eq @string
          end
          
          it "== another (object)" do
            expect(subject).to eq RDF::Literal::XML.new(@obj, :library => @library)
          end
          
          it "== another (value)" do
            expect(subject).to eq subject.dup
          end
        end

        context "with a nodeset" do
          subject {
            @obj = parse_nodeset("<first>foo  bar baz</first> and <second>things</second>", impl)
            RDF::Literal::XML.new(@obj, :library => @library)
          }
          
          it "has equivalent object representation" do
            expect(subject.object).to eq @obj
          end

          it "provides a value" do
            expect(subject.value).to eq (@obj.is_a?(Array) ? @obj.map(&:to_s).join("") : @obj.to_s)
          end
          
          it "== another (object)" do
            expect(subject).to eq RDF::Literal::XML.new(@obj, :library => @library)
          end
          
          it "== another (value)" do
            expect(subject).to eq subject.dup
          end
        end
      end
    end
  end
  
  describe "HTML" do
    %w(Nokogiri REXML).each do |impl|
      next unless Module.constants.map(&:to_s).include?(impl)
      context impl do
        before(:all) { @library = impl.downcase.to_sym}
        
        context "with a node" do
          subject {
            @obj = parse_node("<doc><first>foo  bar baz</first><second>things</second></doc>", impl)
            RDF::Literal::HTML.new(@obj, :library => @library)
          }
          
          it "has equivalent object representation" do
            expect(subject.object).to eq @obj
          end

          it "provides a value" do
            expect(subject.value).to eq @obj.to_s
          end
          
          it "provides value for #to_s" do
            expect(subject.to_s).to eq @obj.to_s
          end
          
          it "== another (object)" do
            expect(subject).to eq subject.dup
          end
          
          it "== another (value)" do
            expect(subject).to eq RDF::Literal::HTML.new(@obj.to_s, :library => @library)
          end
        end

        context "with a node (string)" do
          subject {
            @string = "<doc><first>foo  bar baz</first><second>things</second></doc>"
            @obj = parse_node(@string, impl)
            RDF::Literal::HTML.new(@string, :library => @library)
          }
          
          it "has equivalent object representation" do
            expect(subject.value).to eq @string
          end

          it "provides an object" do
            expect(subject.object.to_s).to eq (impl == "REXML" ? [@obj].to_s : @obj.to_s)
          end
          
          it "provides value for #to_s" do
            expect(subject.value).to eq @string
          end
          
          it "== another (object)" do
            expect(subject).to eq RDF::Literal::HTML.new(@obj, :library => @library)
          end
          
          it "== another (value)" do
            expect(subject).to eq subject.dup
          end
        end

        context "with a nodeset" do
          subject {
            @obj = parse_nodeset("<first>foo  bar baz</first> and <second>things</second>", impl)
            RDF::Literal::HTML.new(@obj, :library => @library)
          }
          
          it "has equivalent object representation" do
            expect(subject.object).to eq @obj
          end

          it "provides a value" do
            expect(subject.value).to eq (@obj.is_a?(Array) ? @obj.map(&:to_s).join("") : @obj.to_s)
          end
          
          it "== another (object)" do
            expect(subject).to eq RDF::Literal::HTML.new(@obj, :library => @library)
          end
          
          it "== another (value)" do
            expect(subject).to eq subject.dup
          end
        end
      end
    end
  end
  
  def parse_node(str, impl)
    case impl
    when "Nokogiri"
      Nokogiri::XML.parse(str)
    else
      REXML::Document.new(str)
    end.root
  end
  
  def parse_nodeset(str, impl)
    parse_node("<foo>#{str}</foo>", impl).children
  end
end
